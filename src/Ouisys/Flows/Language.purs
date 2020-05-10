module Ouisys.Flows.Language (
  module Ouisys.Flows.Language
) where

import Control.Monad.Free (Free, liftF)
import Data.Either (Either)
import Ouisys.Types (CheckSubscriptionToken, PhoneNumber, PhoneNumberSubmissionResult, PinNumber, PinNumberSubmissionResult, SubscriptionStatusResult, GetPinNumberResult)
import Prelude (class Functor, Unit, identity, unit, ($))
import Ouisys.Types.RDS (RDS)

data FlowCommandsF a = 
    -- IdentifyOperatorByIP (Maybe Operator) a 
  -- | AskOperatorFromUser (Operator -> a)
    GetPhoneNumber (PhoneNumber -> a)
  | SetPhoneNumberSubmissionStatus (RDS String PhoneNumber) a
  | ValidatePhoneNumber PhoneNumber (Either String Unit -> a)
  | SubmitPhoneNumber PhoneNumber (Either String PhoneNumberSubmissionResult -> a)
  | GetPinNumber PhoneNumberSubmissionResult (GetPinNumberResult -> a)
  | SetPinNumberSubmissionStatus (RDS String PinNumber) a
  | ValidatePinNumber PinNumber (Either String Unit -> a)
  | SubmitPinNumber PhoneNumberSubmissionResult PinNumber (Either String PinNumberSubmissionResult -> a)
  | CheckSubscriptionStatus CheckSubscriptionToken (Either String SubscriptionStatusResult -> a)
  | SetSubscriptionStatus SubscriptionStatusResult a

derive instance functorTeletypeF :: Functor FlowCommandsF

type FlowCommands = Free FlowCommandsF

getPhoneNumber :: FlowCommands PhoneNumber
getPhoneNumber = liftF $ GetPhoneNumber identity

setPhoneNumberSubmissionStatus :: RDS String PhoneNumber -> Free FlowCommandsF Unit
setPhoneNumberSubmissionStatus e = liftF $ SetPhoneNumberSubmissionStatus e unit

validatePhoneNumber :: PhoneNumber -> FlowCommands (Either String Unit)
validatePhoneNumber phone = liftF $ ValidatePhoneNumber phone identity

submitPhoneNumber :: PhoneNumber -> FlowCommands (Either String PhoneNumberSubmissionResult)
submitPhoneNumber phone = liftF $ SubmitPhoneNumber phone identity


getPinNumber :: PhoneNumberSubmissionResult -> FlowCommands GetPinNumberResult
getPinNumber sub = liftF $ GetPinNumber sub identity

setPinNumberSubmissionStatus :: RDS String PinNumber -> Free FlowCommandsF Unit
setPinNumberSubmissionStatus e = liftF $ SetPinNumberSubmissionStatus e unit

validatePinNumber :: PinNumber -> FlowCommands (Either String Unit)
validatePinNumber pin = liftF $ ValidatePinNumber pin identity

submitPinNumber :: PhoneNumberSubmissionResult -> PinNumber -> FlowCommands (Either String PinNumberSubmissionResult)
submitPinNumber sub pin = liftF $ SubmitPinNumber sub pin identity

checkSubscriptionStatus :: CheckSubscriptionToken -> FlowCommands (Either String SubscriptionStatusResult)
checkSubscriptionStatus token = liftF $ CheckSubscriptionStatus token identity

setSubscriptionStatus :: SubscriptionStatusResult -> Free FlowCommandsF Unit
setSubscriptionStatus e = liftF $ SetSubscriptionStatus e unit