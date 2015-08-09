module MiscShapes.ScanRaw() where
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.List.Split as LS
import TriCad.MathPolar(
  createRightFaces,
  createLeftFaces,
  Slope(..),
  Radius(..),
  flatXSlope,
  flatYSlope,
  createLeftFacesMultiColumns,
  createVerticalCubes,
  )
import TriCad.Points(Point(..))
import TriCad.CornerPoints(CornerPoints(..), (++>), (+++), (++++), Faces(..))
import TriCad.StlCornerPoints((+++^))
import TriCad.StlBase (StlShape(..), newStlShape)
import TriCad.StlFileWriter(writeStlToFile)
import Scan.Parse.Raw(parseToChar, parseToDouble, parseToDoubleFiltered, parseToRadiusFiltered)
import Scan.Transform(minValueIndices, average, reduceRows)

generate = do
  let stlFile = newStlShape "joiner cube" generateCannedDataTriangles
  
  
  
  writeStlToFile stlFile
  putStrLn "done"


{-
This requires the file src/MiscShapes/scanRawData.txt, which is the raw data from the image.
This data was generated by the c++ opencv program.
-}
generateFullDataTriangles  = do
  contents <- BL.readFile "src/MiscShapes/scanRawData.txt"
  let 
      radiiAll = parseToRadiusFiltered  ((*1.35) .  average . minValueIndices 75 ) contents
      radii = [reduceRows 10 x | x <- radiiAll]
      heightPerPixel = 10
      origin = (Point{x_axis=0, y_axis=0, z_axis=50})
      degree = [0,90,180,270,360]
      leftFaces = createLeftFacesMultiColumns origin (tail degree) flatXSlope flatYSlope [0,heightPerPixel..] (tail radii)
      rightFaces =  createRightFaces origin (head degree) flatXSlope flatYSlope [0,heightPerPixel..] (head radii)
      triangles = concat
        [ [FacesFrontTop | x <- [1..4]],
          [FaceFront | x <- [5..224]],
          [FacesBottomFront | x <- [1,2,3,4]]
        ]
        +++^
        createVerticalCubes rightFaces leftFaces
      stlFile = newStlShape "joiner cube" triangles
      
  
  writeStlToFile stlFile
  putStrLn "done"
  
generateCannedDataTriangles =
  let radii = parseToRadiusFiltered  (average . minValueIndices 25 ) $ BL.pack
        "255 12 255;253 255 14 255$254 12 255;253 222 14 255$254 12 255;253 222 14 255$254 12 255;253 222 14 255$254 12 255;253 222 14 255"
      heightPerPixel = 1
      origin = (Point{x_axis=0, y_axis=0, z_axis=50})
      degree = [0,90,180,270,360]
      leftFaces = createLeftFacesMultiColumns origin (tail degree) flatXSlope flatYSlope [0,heightPerPixel..] (tail radii)
      rightFaces =  createRightFaces origin (head degree) flatXSlope flatYSlope [0,heightPerPixel..] (head radii)
  in  [FacesAll | x <- [1..]]
      +++^
      createVerticalCubes rightFaces leftFaces

      
     


{-

       rightFaces =  createRightFaces origin (head degree) flatXSlope flatYSlope [0,heightPerPixel..] (head radii)
   in  createVerticalCubes rightFaces leftFaces
-}
