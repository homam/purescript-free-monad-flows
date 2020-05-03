module Main where

import Control.Monad.Free (Free)
import Data.Foldable (for_)
import Data.List (range)
import Effect (Effect)
import Graphics.Canvas as Canvas
import Math (cos, sin)
import Prelude (Unit, discard, map, negate, void, ($), (*))
import Turtle.CanvasInterpreter (rad, renderTurtleProgOnCanvas)
import Turtle.Language as T
import Data.Int (toNumber)

getXY :: Number -> {x :: Number, y :: Number}
getXY deg = {
  x: radius * cos deg',
  y: radius * sin deg'
} where
  deg' = rad deg
  radius = 100.0


main :: Canvas.Context2D ->  Effect Unit
main ctx = do
  void $ renderTurtleProgOnCanvas ctx $ do
    let list = map (\i -> 30.0 * toNumber i) (range 0 12) 
    for_ list $ \r -> do
      let {x, y} = getXY r
      T.penUp
      T.forward x
      T.left 90.0
      T.forward y
      T.left r
      star
      T.penUp
      T.left $ negate r
      T.forward $ negate y
      T.right 90.0
      T.forward $ negate x

star :: Free T.TurtleCommand Unit
star = do
  T.penDown
  T.right 144.0
  T.forward 100.0
  T.right 144.0
  T.forward 100.0
  T.right 144.0
  T.forward 100.0
  T.right 144.0
  T.forward 100.0
  T.right 144.0
  T.forward 100.0
  T.penUp