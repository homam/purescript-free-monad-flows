{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff-promise"
  , "argonaut-generic"
  , "canvas"
  , "console"
  , "effect"
  , "free"
  , "generics-rep"
  , "integers"
  , "js-timers"
  , "math"
  , "psci-support"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
