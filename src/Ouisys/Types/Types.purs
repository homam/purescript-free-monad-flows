module Ouisys.Types (
  module Ouisys.Types
, module RDS
) where

import Prelude

import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Ouisys.Types.RDS (RDS(..)) as RDS

type Operator = String
type PhoneNumber = String
type PinNumber = String

type GetPinNumberResult = Either Unit PinNumber

newtype PhoneNumberSubmissionResult = PhoneNumberSubmissionResult {}
newtype PinNumberSubmissionResult = PinNumberSubmissionResult {}
newtype CheckSubscriptionToken = CheckSubscriptionToken {}
newtype SubscriptionStatusResult = SubscriptionStatusResult {}

class ToSubscriptionStatusResult a where
  toSubscriptionStatusResult :: a -> SubscriptionStatusResult

instance pinNumberSubmissionResultToSubscriptionStatusResult :: ToSubscriptionStatusResult PinNumberSubmissionResult where
  toSubscriptionStatusResult _ = SubscriptionStatusResult {}

derive instance genericSubscriptionStatusResult :: Generic SubscriptionStatusResult _
instance showSubscriptionStatusResult :: (Show e, Show r) => Show SubscriptionStatusResult where
  show a = genericShow a
instance encodeJsonSubscriptionStatusResult :: (EncodeJson e, EncodeJson r) => EncodeJson SubscriptionStatusResult where
  encodeJson a = genericEncodeJson a
instance decodeJsonSubscriptionStatusResult :: (DecodeJson e, DecodeJson r) => DecodeJson SubscriptionStatusResult where
  decodeJson a = genericDecodeJson a

class ToCheckSubscriptionStatusToken a where
  toCheckSubscriptionStatusToken :: a -> CheckSubscriptionToken

instance toCheckSubscriptionStatusTokenPinNumberSubmissionResult :: ToCheckSubscriptionStatusToken PinNumberSubmissionResult where
  toCheckSubscriptionStatusToken _ = CheckSubscriptionToken {}