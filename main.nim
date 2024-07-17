import std/streams
import std/strformat

proc printHeader(f: FileStream, width, height: int): void =
    # Header
    f.writeLine("P6") # "P6" means this is a RGB color image in ASCII format
    f.writeLine(fmt"{width} {height}")
    f.writeLine("255") # is the maximum value for each color
   
proc drawGreenBox(f: FileStream, width, height: int): void =

     # Image Data
    for i in 0..<width:
        for j in 0..<height:
            f.write(chr(0), chr(255), chr(0)) # Green pixel

proc main(): void =
    let f = newFileStream("sample.ppm", fmWrite)
    defer: f.close

    printHeader(f, 100, 100)
    drawGreenBox(f, 100, 100)

when isMainModule:
    main()