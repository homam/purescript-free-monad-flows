module Ouisys.Backend.Api where

import Ouisys.Types
import Data.Either (Either)
import Effect.Aff (Aff)

type Api = {
    submitPhoneNumber :: {phone :: PhoneNumber} -> Aff (Either String PhoneNumberSubmissionResult)
  , submitPinNumber :: {phoneNumberSubmissionResult :: PhoneNumberSubmissionResult, pin :: PinNumber} -> Aff (Either String PinNumberSubmissionResult)
  , getClickToSMSDetails :: Aff (Either String ClickToSMSDetails)
}
