# PureScript Free Turtle interpreter

A demonstration of a Turtle interpreter based on the Free monad, with HTML Canvas graphics support.

![Stars][stars]

```purescript
main :: Canvas.Context2D ->  Effect Unit
main ctx = do
  void $ renderTurtleProgOnCanvas ctx star

star :: Free T.TurtleCommand Unit
star = do
  forward 50.0
  left 90.0
  forward 15.0
  left $ negate 90.0
  penDown
  right 144.0
  forward 100.0
  right 144.0
  forward 100.0
  right 144.0
  forward 100.0
  right 144.0
  forward 100.0
  right 144.0
  forward 100.0
  penUp
  left $ 90.0
  forward $ negate 15.0
  left $ negate 90.0
  forward $ negate 50.0
```

[stars]: https://i.imgur.com/N6FZnni.png
