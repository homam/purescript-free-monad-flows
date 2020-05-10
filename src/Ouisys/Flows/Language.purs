module Ouisys.Flows.Language (
  module Ouisys.Flows.Language
) where

import Control.Monad.Free (Free, liftF)
import Data.Either (Either)
import Ouisys.Types (CheckSubscriptionToken, GetPinNumberResult, PhoneNumber, PhoneNumberSubmissionResult, PinNumber, PinNumberSubmissionResult, SubscriptionStatusResult, ClickToSMSDetails)
import Ouisys.Types.RDS (RDS)
import Prelude (class Functor, Unit, identity, unit, ($))

data FlowCommandsF next = 
    -- IdentifyOperatorByIP (Maybe Operator) next 
  -- | AskOperatorFromUser (Operator -> next)
    GetPhoneNumber (PhoneNumber -> next)
  | SetPhoneNumberSubmissionStatus (RDS String PhoneNumber) next
  | ValidatePhoneNumber PhoneNumber (Either String Unit -> next)
  | SubmitPhoneNumber PhoneNumber (Either String PhoneNumberSubmissionResult -> next)
  | GetPinNumber PhoneNumberSubmissionResult (GetPinNumberResult -> next)
  | SetPinNumberSubmissionStatus (RDS String PinNumber) next
  | ValidatePinNumber PinNumber (Either String Unit -> next)
  | SubmitPinNumber PhoneNumberSubmissionResult PinNumber (Either String PinNumberSubmissionResult -> next)
  | CheckSubscriptionStatus CheckSubscriptionToken (Either String SubscriptionStatusResult -> next)
  | SetSubscriptionStatus SubscriptionStatusResult next
  | GetClickToSMSDetails (Either String ClickToSMSDetails -> next)
  | ClickToSMS ClickToSMSDetails next

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

getClickToSMSDetails :: FlowCommands (Either String ClickToSMSDetails)
getClickToSMSDetails = liftF $ GetClickToSMSDetails identity

clickToSMS :: ClickToSMSDetails  -> Free FlowCommandsF Unit
clickToSMS e = liftF $ ClickToSMS e unit