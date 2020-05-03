module Main where

import Control.Monad.Free (Free)
import Data.Foldable (for_)
import Data.Int (toNumber)
import Data.List (range)
import Effect (Effect)
import Graphics.Canvas as Canvas
import Math (cos, sin)
import Prelude (Unit, discard, map, negate, void, ($), (*))
import Turtle.CanvasInterpreter (rad, renderTurtleProgOnCanvas)
import Turtle.Language as T

getXY :: Number -> {x :: Number, y :: Number}
getXY deg = {
  x: radius * cos deg',
  y: radius * sin deg'
} where
  deg' = rad deg
  radius = 120.0


main :: Canvas.Context2D ->  Effect Unit
main ctx = do
  void $ renderTurtleProgOnCanvas ctx $ do
    star
    let list = map (\i -> 24.0 * toNumber i) (range 0 15) 
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
  T.forward 50.0
  T.left 90.0
  T.forward 15.0
  T.left $ negate 90.0
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
  T.left $ 90.0
  T.forward $ negate 15.0
  T.left $ negate 90.0
  T.forward $ negate 50.0
