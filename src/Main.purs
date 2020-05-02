module Main where

import Prelude (Unit, discard, void, ($))
import Turtle.CanvasInterpreter (renderTurtleProgOnCanvas) 
import Control.Monad.Free (Free)
import Effect (Effect)
import Graphics.Canvas as Canvas
import Turtle.Language as T


main :: Canvas.Context2D ->  Effect Unit
main ctx = do
  void $ renderTurtleProgOnCanvas ctx $ do
    star
    T.penUp
    T.forward 40.0
    T.left 100.0
    T.penDown
    T.changeColor T.Red
    star

star :: Free T.TurtleCommand Unit
star = do
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