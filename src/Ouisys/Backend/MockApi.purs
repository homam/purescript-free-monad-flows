module Ouisys.Backend.MockApi (
  module Ouisys.Backend.Api, mockApi
) where

import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Data.String as String
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (delay)
import Ouisys.Backend.Api (Api)
import Ouisys.Types (PhoneNumberSubmissionResult(..), PinNumberSubmissionResult(..))
import Prelude (discard, negate, pure, ($), (/=), (<>))
  
mockApi :: Api
mockApi = {
  submitPhoneNumber : \ {phone} -> do 
    delay (Milliseconds 1000.0) -- simulate delaying response from the servec
    let indexOf0 = fromMaybe (-1) (String.indexOf (String.Pattern "0") phone ) 
    if indexOf0 /= 0 then
      pure $ Left $ "Server Error: " <> phone <> " must start with 0."
    else
      pure $ Right $ PhoneNumberSubmissionResult {}
  , 
  submitPinNumber : \ {phoneNumberSubmissionResult, pin} -> do
    delay (Milliseconds 1000.0) -- simulate delaying response from the server
    let indexOf0 = fromMaybe (-1) (String.indexOf (String.Pattern "0000") pin ) 
    if indexOf0 /= 0 then
      pure $ Left "Server Error: Pin is 0000"
    else
      pure $ Right $ PinNumberSubmissionResult {}
  , getClickToSMSDetails : do
      delay (Milliseconds 1000.0) -- simulate delaying response from the servec
      pure $ Right {shortcode: "0000", keyword: "START"}
}
