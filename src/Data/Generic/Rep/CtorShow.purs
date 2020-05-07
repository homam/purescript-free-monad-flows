module Data.Generic.Rep.CtorShow
  ( class GenericCtorShow
  , genericCtorShow'
  , genericCtorShow
  ) where

import Data.Generic.Rep
import Data.Symbol (class IsSymbol, SProxy(..), reflectSymbol)

class GenericCtorShow a where
  genericCtorShow' :: a -> String

instance genericShowNoConstructors :: GenericCtorShow NoConstructors where
  genericCtorShow' a = genericCtorShow' a

instance genericShowSum :: (GenericCtorShow a, GenericCtorShow b) => GenericCtorShow (Sum a b) where
  genericCtorShow' (Inl a) = genericCtorShow' a
  genericCtorShow' (Inr b) = genericCtorShow' b

instance genericShowConstructor
  :: (IsSymbol name)
  => GenericCtorShow (Constructor name a) where
  genericCtorShow' (Constructor a) = ctor
    where
      ctor :: String
      ctor = reflectSymbol (SProxy :: SProxy name)

-- | A `Generic` implementation of the `show` member from the `Show` type class.
genericCtorShow :: forall a rep. Generic a rep => GenericCtorShow rep => a -> String
genericCtorShow x = genericCtorShow' (from x)