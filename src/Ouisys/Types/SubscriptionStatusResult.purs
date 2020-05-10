module Ouisys.Types.SubscriptionStatusResult

where

import Prelude
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)

newtype SubscriptionStatusResult = SubscriptionStatusResult {}

derive instance genericSubscriptionStatusResult :: Generic SubscriptionStatusResult _
instance showSubscriptionStatusResult :: (Show e, Show r) => Show SubscriptionStatusResult where
  show a = genericShow a
instance encodeJsonSubscriptionStatusResult :: (EncodeJson e, EncodeJson r) => EncodeJson SubscriptionStatusResult where
  encodeJson a = genericEncodeJson a
instance decodeJsonSubscriptionStatusResult :: (DecodeJson e, DecodeJson r) => DecodeJson SubscriptionStatusResult where
  decodeJson a = genericDecodeJson a



class ToSubscriptionStatusResult a where
  toSubscriptionStatusResult :: a -> SubscriptionStatusResult

