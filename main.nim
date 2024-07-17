import std/logging
import std/streams
import std/strformat

type RGB = (uint8, uint8, uint8)

const BLACK: RGB = (0, 0, 0)
const WHITE: RGB = (255, 255, 255)
const BLUE: RGB = (0, 94, 184)

const WIDTH = 300
const HEIGHT = 180

const SAMPLE = "sample.ppm"

# Log to the console
var logger = newConsoleLogger()

proc printHeader(f: FileStream, width, height: int): void =
    # Header
    f.writeLine("P3") # "P3" means this is a RGB color image in ASCII format
                      # Use "P6" for raw format but ASCII is better for debbuging
    f.writeLine(fmt"{width} {height}")
    f.writeLine("255") # is the maximum value for each color

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

proc rasterize(f: FileStream, width, height: int, fun: proc(u, v: float): RGB): void =
    # Data is a raster of Height rows, in order from top to bottom.
    # Each row consists of Width pixels, in order from left to right.

    for y in 0..<height:
      for x in 0..<width:
        let u = float(x) / float(width - 1)
        let v = float(y) / float(height - 1)
        let (r, g, b) = fun(u, v)
        f.write(fmt"{r:03} {g:03} {b:03}  ")
      f.write("\n") 

proc main(): void =
    let f = newFileStream(SAMPLE, fmWrite)
    defer: f.close

    printHeader(f, WIDTH, HEIGHT)
    #drawGreenBox(f, 100, 100)
    rasterize(f, WIDTH, HEIGHT, crossFunc)

when isMainModule:
    main()
    logger.log(lvlInfo, fmt"{SAMPLE} has been generated")
