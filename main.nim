import std/logging
import std/math
import std/os
import std/parseopt
import std/streams
import std/strformat

type RGB = (uint8, uint8, uint8)

const BLACK: RGB = (0, 0, 0)
const BLUE: RGB = (0, 94, 184)
const GREEN: RGB = (0, 255, 0)
const RED: RGB = (255, 0, 0)
const WHITE: RGB = (255, 255, 255)

const SAMPLE = "sample.ppm"

type PPM = object
  fs: FileStream
  width: int
  height: int

# Log to the console
var logger = newConsoleLogger()

proc createPPM(filename: string, width, height: int): PPM =
    let f = newFileStream(filename, fmWrite)
    # Header
    f.writeLine("P3") # "P3" means this is a RGB color image in ASCII format
                      # Use "P6" for raw format but ASCII is better for debbuging
    f.writeLine(fmt"{width} {height}")
    f.writeLine("255") # is the maximum value for each color
    PPM(fs: f, width: width, height: height)

proc closePPM(self: PPM): void =
  self.fs.close

proc rasterize(self: PPM, fun: proc(u, v: float): RGB): PPM =
    # Data is a raster of Height rows, in order from top to bottom.
    # Each row consists of Width pixels, in order from left to right.

    for y in 0..<self.height:
      for x in 0..<self.width:
        let u = float(x) / float(self.width - 1)
        let v = float(y) / float(self.height - 1)
        let (r, g, b) = fun(u, v)
        self.fs.write(fmt"{r:03} {g:03} {b:03}  ")
      self.fs.write("\n")

    self

func boxFunc(u, v: float): RGB =
  GREEN

func circleFunc(u, v: float): RGB =
  # The point is in the circle if its distance from the center is less than the radius
  # Let's draw the japan flag
  let radius = 0.3
  let distance = sqrt((u - 0.5)*(u - 0.5) + (v - 0.5)*(v - 0.5))
  if distance < radius:
    RED
  else:
    WHITE

func crossFunc(u, v: float): RGB =
  # As we are dealing with integer converted to float we need to introduce an imprecision.
  # In fact this imprecision will define the thickness of the cross.
  const delta = 0.05

  if u < v + delta and u > v - delta: # f(x) = y , the first diagonal
    WHITE
  elif v < -u + 1 + delta and v > -u + 1 - delta: # f(x) = -x + 1 , the second one
    WHITE
  else:
    BLUE

proc help(status: int): void =
  let progname = getAppFilename().extractFilename()
  echo fmt"""
Usage: {progname} [OPTION...] [output.ppm]

  -s, --shape        circle|box|cross (default is cross)
  -h, --help         display this help

If no output.ppm is given sample.ppm will be used.
  """
  system.quit(status)

when isMainModule:
    # We are expecting --type [circle|box|cross] <sample.ppm> 
    var filename = SAMPLE
    var shapeFunc = crossFunc 
    # for cross we are drawing scotland flag so a rectangle is better 
    var width = 300
    var height = 180

    var p = initOptParser()
    for kind, key, val in p.getopt():
      case kind
      of cmdShortOption, cmdLongOption:
        case key
        of "shape", "s":
          p.next()
          case p.key
          of "circle":
            shapeFunc = circleFunc
            # for circle a square is better 
            width = 200
            height = 200
          of "cross": shapeFunc = crossFunc
          of "box":  shapeFunc = boxFunc
          else:
            logger.log(lvlError, fmt"shape {p.key} is invalid")
            help(1)
        of "help", "h":
          help(0)
        else:
          logger.log(lvlError, fmt"option {key} is unknown")
          help(1)
      of cmdArgument:
        filename = key
      else:
        logger.log(lvlError, fmt"{kind} is unknown")
        help(1)

    createPPM(filename, width, height).rasterize(shapeFunc).closePPM()
    logger.log(lvlInfo, fmt"{filename} has been generated")
