module Turtle.Language where
import Control.Monad.Free (Free, liftF)
import Data.Generic.Rep as Rep
import Data.Generic.Rep.CtorShow (genericCtorShow)
import Prelude (class Functor, class Show, Unit, unit, ($))

type Angle = Number
type Distance = Number
data Color = Red | Blue | Green | Yellow | Orange | Purple | Black | CustomColor String

data TurtleCommand a = Forward Distance a 
  | Arc Distance Angle a
  | Right Angle a
  | Left Angle a
  | PenUp a
  | PenDown a 
  | ChangeColor Color a

derive instance functorTurtleCommand :: Functor TurtleCommand

derive instance genericTurtleCommand :: Rep.Generic (TurtleCommand a) _

instance showTurtleCommand :: Show (TurtleCommand a) where
  show x = genericCtorShow x

type TurtleProgram a = Free TurtleCommand a

forward :: Distance -> TurtleProgram Unit
forward d = liftF $ Forward d unit

arc :: Distance -> Angle -> TurtleProgram Unit
arc d a = liftF $ Arc d a unit

left :: Distance -> TurtleProgram Unit
left d = liftF $ Left d unit

right :: Distance -> TurtleProgram Unit
right d = liftF $ Right d unit

penUp :: TurtleProgram Unit
penUp = liftF $ PenUp unit

penDown :: TurtleProgram Unit
penDown = liftF $ PenDown unit

changeColor :: Color -> TurtleProgram Unit
changeColor c = liftF $ ChangeColor c unit