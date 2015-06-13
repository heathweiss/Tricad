module MiscShapes.RvVentCaps(hello, debug, stlFile, writeRvCapStlFile) where
      
import TriCad.MathPolar(
  slopeAdjustedForVerticalAngle,
  createTopFaces,
  createBottomFaces,
  createTopFacesWithVariableSlope,
  createBottomFacesWithVariableSlope,
  radiusAdjustedForZslope,
  xValue,
  xyQuadrantAngle,
  QuadrantAngle(..),
  createCornerPoint,
  Slope(..),
  Radius(..),
  flatXSlope,
  flatYSlope,
  )
import TriCad.Points(Point(..))
import TriCad.CornerPoints(CornerPoints(..), (++>), (+++), (++++), Faces(..))
import TriCad.StlCornerPoints((+++^))
import TriCad.StlBase (StlShape(..), newStlShape)
import TriCad.CornerPointsFaceExtraction ( extractTopFace, extractBottomFrontLine, extractFrontTopLine, extractBackTopLine, extractBottomFace, extractBackBottomLine, extractFrontFace )

import TriCad.CornerPointsFaceConversions(lowerFaceFromUpperFace, backBottomLineFromBottomFrontLine, backTopLineFromFrontTopLine, frontTopLineFromBackTopLine, upperFaceFromLowerFace, bottomFrontLineFromBackBottomLine)
import TriCad.CornerPointsTranspose ( transposeCornerPointsZ, transposeCornerPointsX, transposeCornerPointsY)
import TriCad.CornerPointsDebug((+++^?), CubeName(..), CubeDebug(..), CubeDebugs(..))
import TriCad.StlFileWriter(writeStlToFile)

{--------------------------- overview -------------------------------------------
The cap has to be printed upside-down, but flip it using Slic3r.
-}

--test for module connection
hello = do
  putStrLn "hello from rv vent caps"

stlFile = newStlShape "rv vent cap" $ innerRiserJoinerTriangles
                                      ++ innerRiserTriangles
                                      ++ topPlateInnerSectionTriangles
                                      ++ topPlateCentralJoinerTriangles
                                      ++ topPlateDripCapJoinerTriangles
                                      ++ dripCapTriangles

writeRvCapStlFile = writeStlToFile stlFile

debug =  [CubeName "" | x <- [1..]]
    +++^?
    dripCapCubes

topOfPlateOrigin = (Point{x_axis=0, y_axis=0, z_axis=23})
btmOfPlateOrigin = topOfRiserOrigin

btmOfRiserOrigin = (Point{x_axis=0, y_axis=0, z_axis=0})
topOfRiserOrigin = (Point{x_axis=0, y_axis=0, z_axis=20})

btmOfDripCapOrigin = (Point{x_axis=0, y_axis=0, z_axis=10})


--this is for all angles
angles = [0,10..360]

--radius for the central piece of the top plate
topPlateInnerCoverRadius =  [Radius 0 | x <- [1..37]]

--radius for the ring that sits in the existing trailer piece.
innerConnectorRingRadius = [Radius 23 | x <- [1..37]] 
outerConnectorRingRadius = map (\(Radius x) -> Radius (x + 10)) innerConnectorRingRadius

--radius for the outer ring that forms the rain shield
--This is still inside of the drip cap joiner.
topPlateMiddleCoverRadius = map (\(Radius x) -> Radius (x + 12)) outerConnectorRingRadius

--the part of the top plate that joins the drip cap (the sections that hangs down.)
topPlateDripCapJoinerOuterRadius =  map (\(Radius x) -> Radius (x + 3)) topPlateMiddleCoverRadius

{-------------------- drip cap -------------------------}
dripCapTriangles =
   [FacesAll | x <- [1..36]]
  +++^
  dripCapCubes
  
dripCapCubes =  ring
    btmOfDripCapOrigin
    topPlateMiddleCoverRadius
    topPlateDripCapJoinerOuterRadius
    btmOfPlateOrigin
    topPlateMiddleCoverRadius
    topPlateDripCapJoinerOuterRadius
    angles 

{------------------- top plate drip cap joiner ---
the part of the top plate that joins the drip cap (the sections that hangs down.)

--}
topPlateDripCapJoinerTriangles =
  [FacesAll | x <- [1..36]]
  +++^
  topPlateDripCapJoinerCubes
  
  

topPlateDripCapJoinerCubes =
  ring
    btmOfPlateOrigin
    topPlateMiddleCoverRadius
    topPlateDripCapJoinerOuterRadius
    topOfPlateOrigin
    topPlateMiddleCoverRadius
    topPlateDripCapJoinerOuterRadius
    angles 


{---------------------------
Part of top plate.
Section between the riser joiner and the drip cap joiner
-}
topPlateCentralJoinerTriangles =
   [FacesAll | x <- [1..36]]
   +++^
   topPlateCentralJoinerCubes

topPlateCentralJoinerCubes =
  ring
    btmOfPlateOrigin
    outerConnectorRingRadius
    topPlateMiddleCoverRadius
    topOfPlateOrigin
    outerConnectorRingRadius
    topPlateMiddleCoverRadius
    angles 
    

{---------------------- top plate central section ---------------------------------
The section of the top plate that is inside of the inner riser ring.

Left a small hole in the middle, so slic3r does not have to repair it.
-}
topPlateInnerSectionTriangles =  [FacesBackBottomFrontTop | x <- [1..36]]
                                 +++^
                                 topPlateInnerSectionCubes

topPlateInnerSectionCubes = ring
                              btmOfPlateOrigin
                              topPlateInnerCoverRadius
                              innerConnectorRingRadius
                              topOfPlateOrigin
                              topPlateInnerCoverRadius
                              innerConnectorRingRadius
                              angles

{-------------------------- top plate to inner riser joiner  section -----------
Part of the top plate. Joins the top plate to the inner riser.
-}

innerRiserJoinerTriangles = [FacesBackBottomFrontTop | x <- [1..36]]
   +++^
   innerRiserJoinerCubes

innerRiserJoinerCubes = ring btmOfPlateOrigin innerConnectorRingRadius outerConnectorRingRadius topOfPlateOrigin
                      innerConnectorRingRadius outerConnectorRingRadius angles
 

{------------------------- inner riser ring----------------------------------
This is the ring that sits on the existing cap.

Make it thicker so that holes can be drilled for studs

Make gaps between studs for venting.

-}

innerRiserTriangles = concat [

                               [FacesAll | x <- [1..3]],
                               [FacesNada | x <- [4..9]],
                               [FacesAll | x <- [10..12]],
                               [FacesNada | x <- [13..18]],
                               [FacesAll | x <- [19..21]],
                               [FacesNada | x <- [22..27]],
                               [FacesAll | x <- [27..29]],
                               [FacesNada | x <- [30..36]]
                             ]
                      +++^
                      innerRiserCubes

innerRiserCubes = ring btmOfRiserOrigin innerConnectorRingRadius outerConnectorRingRadius topOfRiserOrigin
                 innerConnectorRingRadius outerConnectorRingRadius angles
 

{--------- ring ------------------------
Create a ring function.
-}
ring btmOrigin btmInnerRadius btmOuterRadius topOrigin topInnerRadius topOuterRadius angles  =
  topFaces ++++ btmFaces
   where
     topFaces =
       (map (extractFrontTopLine) (createTopFaces topOrigin topOuterRadius angles flatXSlope (PosYSlope 0)))
       ++++
       (map
        (backTopLineFromFrontTopLine . extractFrontTopLine)
        (createTopFaces topOrigin topInnerRadius angles flatXSlope flatYSlope)
       )
     
     btmFaces =
       (map (extractBottomFrontLine)
        (createBottomFaces btmOrigin btmOuterRadius angles flatXSlope flatYSlope))
       ++++
       (map
        (backBottomLineFromBottomFrontLine . extractBottomFrontLine)
        (createBottomFaces btmOrigin btmInnerRadius angles flatXSlope flatYSlope)
       )
  
 

