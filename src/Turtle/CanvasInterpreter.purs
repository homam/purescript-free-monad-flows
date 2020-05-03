module Turtle.CanvasInterpreter where
  
import Prelude
import Control.Monad.Free (runFreeM)
import Control.Monad.State (State, evalState, get, modify, put)
import Data.Foldable (foldl)
import Effect (Effect)
import Graphics.Canvas as Canvas
import Math (cos, sin, pi, (%))
import Turtle.Language (Angle, Color(..), Distance, TurtleCommand(..), TurtleProgram, penDown, penUp)

type Turtle = { x :: Distance, y :: Distance, angle :: Angle, isPenDown :: Boolean }

initTurtle :: Turtle
initTurtle = { x: 0.0, y: 0.0, angle: 0.0, isPenDown: true }

interpretTurtleProgram :: forall a. TurtleProgram a -> Canvas.Context2D -> Effect Canvas.Context2D
interpretTurtleProgram turtleProg ctx = foldl (>>=) (pure ctx) (interpretTurtleProgram' turtleProg)

interpretTurtleProgram' :: forall a. TurtleProgram a -> Array (Canvas.Context2D -> Effect Canvas.Context2D)
interpretTurtleProgram' prog = 
  evalState turtleProgramState initTurtle

  where 
    prog' :: TurtleProgram (Array (Canvas.Context2D -> Effect Canvas.Context2D))
    prog' = const [] <$> prog

    turtleProgramState :: State Turtle  (Array (Canvas.Context2D -> Effect Canvas.Context2D))
    turtleProgramState = interpretTurtleProgram'' prog'

-- | A natural transformation from `TurtleProg` to `State Turtle`.
interpretTurtleProgram'' :: TurtleProgram (Array (Canvas.Context2D -> Effect Canvas.Context2D))
                         -> State Turtle  (Array (Canvas.Context2D -> Effect Canvas.Context2D))
interpretTurtleProgram'' = runFreeM interpret where
  interpret :: TurtleCommand (TurtleProgram (Array (Canvas.Context2D -> Effect Canvas.Context2D)))
            -> State Turtle  (TurtleProgram (Array (Canvas.Context2D -> Effect Canvas.Context2D)))
  interpret (Forward r rest) = do
    turtle <- get 
    let x' = turtle.x + adjacent r turtle.angle
        y' = turtle.y + opposite r turtle.angle
        instr = lineTo' x' y'
    put $ turtle {x = x', y = y'}

    pure $ (\prog -> prog <> [instr]) <$> rest

  interpret (Arc r arcAngleDeg rest) = do
    turtle <- get
    let angleEnd = turtle.angle + rad arcAngleDeg
        angle'   = angleEnd + rad 90.0
        x'       = turtle.x + adjacent r angleEnd
        y'       = turtle.y + opposite r angleEnd
        instr    = arc' turtle.x turtle.y r turtle.angle angleEnd

    put $ turtle {x = x', y = y', angle = angle'}
    pure $ rest <#> ((<>) [instr])

  interpret (Right angleDeg rest) = do
    let angle = rad angleDeg
    _ <- modify $ \turtle -> turtle {angle = turtle.angle + angle}
    pure rest

  interpret (Left angleDeg rest) = interpret (Right (-1.0 * angleDeg) rest)

  interpret (PenUp rest) = do
    {isPenDown} <- get
    void $ modify $ \turtle -> turtle {isPenDown = false}
    pure $ (\prog -> prog <> (if isPenDown then [endStroke'] else [])) <$> rest

  interpret (PenDown rest) = do
    {x, y} <- modify $ \turtle -> turtle {isPenDown = true}
    pure $ (\prog -> prog <> [beginStroke', moveTo' x y]) <$> rest

  interpret (ChangeColor col rest) = do
    pure $ (\prog -> prog <> [setStrokeStyle' $ colorToCanvasStyle]) <$> rest
    where
      colorToCanvasStyle :: String
      colorToCanvasStyle = case col of
        Red -> "red"
        Green -> "green"
        Blue -> "blue"
        Purple -> "purple"
        Black -> "black"
        Orange -> "orange"
        Yellow -> "yellow"
        CustomColor str -> str


adjacent :: Number -> Number -> Number
adjacent r angle = r * cos angle

opposite :: Number -> Number -> Number
opposite r angle = r * sin angle

rad :: Number -> Number
rad angleDegrees = (2.0 * pi * (angleDegrees % 360.0)) / 360.0

lineTo' :: Distance -> Distance -> Canvas.Context2D -> Effect Canvas.Context2D
lineTo' x y c = Canvas.lineTo c x y *> pure c

arc' :: Distance -> Distance -> Distance -> Angle -> Angle -> Canvas.Context2D -> Effect Canvas.Context2D
arc' x y r s e c = Canvas.arc c { start: s, end: e, radius: r, x: x, y: y }  *> pure c

endStroke' :: Canvas.Context2D -> Effect Canvas.Context2D
endStroke' c = Canvas.stroke c *> pure c

beginStroke' :: Canvas.Context2D -> Effect Canvas.Context2D
beginStroke' c = Canvas.beginPath c *> pure c

moveTo' :: Distance -> Distance -> Canvas.Context2D -> Effect Canvas.Context2D
moveTo' x y c = Canvas.moveTo c x y *> pure c

setStrokeStyle' :: String -> Canvas.Context2D -> Effect Canvas.Context2D
setStrokeStyle' color c = Canvas.setStrokeStyle c color *> pure c

setLineWidth' :: Number -> Canvas.Context2D -> Effect Canvas.Context2D
setLineWidth' w c = Canvas.setLineWidth c w *> pure c


renderTurtleProgOnCanvas :: Canvas.Context2D -> TurtleProgram Unit -> Effect Canvas.Context2D
renderTurtleProgOnCanvas ctx prog =
  initCanvas ctx >>=
  moveTo' 0.0 0.0 >>=
  interpretTurtleProgram (penDown *> prog *> penUp)
  where
    initCanvas :: Canvas.Context2D -> Effect Canvas.Context2D
    initCanvas c = 
      setLineWidth' 2.0 c >>= setStrokeStyle' "purple"
