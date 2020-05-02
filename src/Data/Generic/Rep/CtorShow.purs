module Data.Generic.Rep.CtorShow
  ( class GenericCtorShow
  , genericCtorShow'
  , genericCtorShow
  , class GenericShowArgs
  , genericShowArgs
  ) where

import Prelude (class Show, show, (<>))
import Data.Generic.Rep
import Data.Symbol (class IsSymbol, SProxy(..), reflectSymbol)

class GenericCtorShow a where
  genericCtorShow' :: a -> String

class GenericShowArgs a where
  genericShowArgs :: a -> Array String

instance genericShowNoConstructors :: GenericCtorShow NoConstructors where
  genericCtorShow' a = genericCtorShow' a

instance genericShowArgsNoArguments :: GenericShowArgs NoArguments where
  genericShowArgs _ = []

instance genericShowSum :: (GenericCtorShow a, GenericCtorShow b) => GenericCtorShow (Sum a b) where
  genericCtorShow' (Inl a) = genericCtorShow' a
  genericCtorShow' (Inr b) = genericCtorShow' b

instance genericShowArgsProduct
    :: (GenericShowArgs a, GenericShowArgs b)
    => GenericShowArgs (Product a b) where
  genericShowArgs (Product a b) = genericShowArgs a <> genericShowArgs b

instance genericShowConstructor
  :: (IsSymbol name)
  => GenericCtorShow (Constructor name a) where
  genericCtorShow' (Constructor a) = ctor
    where
      ctor :: String
      ctor = reflectSymbol (SProxy :: SProxy name)

instance genericShowArgsArgument :: Show a => GenericShowArgs (Argument a) where
  genericShowArgs (Argument a) = [show a]

-- | A `Generic` implementation of the `show` member from the `Show` type class.
genericCtorShow :: forall a rep. Generic a rep => GenericCtorShow rep => a -> String
genericCtorShow x = genericCtorShow' (from x)