module Ouisys.Types.RDS where

import Prelude (class Show)
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)

data RDS e r = NothingYet | Loading | Success r | Failure e
derive instance genericRDS :: Generic (RDS e r) _
instance showRDS :: (Show e, Show r) => Show (RDS e r) where
  show a = genericShow a
instance encodeJsonRDS :: (EncodeJson e, EncodeJson r) => EncodeJson (RDS e r) where
  encodeJson a = genericEncodeJson a
instance decodeJsonRDS :: (DecodeJson e, DecodeJson r) => DecodeJson (RDS e r) where
  decodeJson a = genericDecodeJson a