module Ouisys.Flows.FlowCommands where

import Prelude

import Control.Monad.Free (Free, liftF)
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Generic.Rep (genericEncodeJson)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)

type Operator = String
type PhoneNumber = String
type PinNumber = String

data RDS e r = NothingYet | Loading | Success r | Failure e
derive instance genericRDS :: Generic (RDS e r) _
instance showRDS :: (Show e, Show r) => Show (RDS e r) where
  show a = genericShow a
instance encodeJsonRDS :: (EncodeJson e, EncodeJson r) => EncodeJson (RDS e r) where
  encodeJson a = genericEncodeJson a
instance decodeJsonRDS :: (DecodeJson e, DecodeJson r) => DecodeJson (RDS e r) where
  decodeJson a = genericDecodeJson a

data FlowCommandsF a = 
    -- IdentifyOperatorByIP (Maybe Operator) a 
  -- | AskOperatorFromUser (Operator -> a)
    GetPhoneNumber (PhoneNumber -> a)
  | SetPhoneNumberSubmissionStatus (RDS String PhoneNumber) a
  | ValidatePhoneNumber PhoneNumber (Either String Unit -> a)
  | SubmitPhoneNumber PhoneNumber (Either String Unit -> a)
  | GetPinNumber (PinNumber -> a)

derive instance functorTeletypeF :: Functor FlowCommandsF

type FlowCommands = Free FlowCommandsF

getPhoneNumber :: FlowCommands PhoneNumber
getPhoneNumber = liftF $ GetPhoneNumber identity

setPhoneNumberSubmissionStatus :: RDS String PhoneNumber -> Free FlowCommandsF Unit
setPhoneNumberSubmissionStatus e = liftF $ SetPhoneNumberSubmissionStatus e unit

validatePhoneNumber :: PhoneNumber -> FlowCommands (Either String Unit)
validatePhoneNumber phone = liftF $ ValidatePhoneNumber phone identity

submitPhoneNumber :: PhoneNumber -> FlowCommands (Either String Unit)
submitPhoneNumber phone = liftF $ SubmitPhoneNumber phone identity

