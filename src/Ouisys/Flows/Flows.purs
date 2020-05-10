module Ouisys.Flows where

import Ouisys.Flows.Language
import Prelude (bind, discard, pure, ($), (=<<))
import Data.Either (Either(..))
import Ouisys.Types (PhoneNumber, PhoneNumberSubmissionResult, PinNumber, PinNumberSubmissionResult)

-- | Get a phone number and validate it using client-side validation rules
getPhoneNumberFlow :: FlowCommands PhoneNumber
getPhoneNumberFlow = do 
  phone <- getPhoneNumber
  handle phone =<< validatePhoneNumber phone
  where 
    handle _ (Left error) = do
      setPhoneNumberSubmissionStatus $ Failure error
      getPhoneNumberFlow
    handle phone (Right _) = pure phone

submitPhoneNumberFlow :: FlowCommands PhoneNumberSubmissionResult
submitPhoneNumberFlow = do 
  phone <- getPhoneNumberFlow
  setPhoneNumberSubmissionStatus $ Loading
  handle phone =<< submitPhoneNumber phone
  where 
    handle _ (Left l) = do
      setPhoneNumberSubmissionStatus $ Failure l
      submitPhoneNumberFlow
    handle phone (Right r) = do
      setPhoneNumberSubmissionStatus $ Success phone
      pure  r


---


getPinNumberFlow :: FlowCommands PinNumber
getPinNumberFlow = do 
  pin <- getPinNumber
  handle pin =<< validatePinNumber pin
  where 
    handle _ (Left error) = do
      setPinNumberSubmissionStatus $ Failure error
      getPinNumberFlow
    handle pin (Right _) = pure pin
      
submitPinNumberFlow :: PhoneNumberSubmissionResult -> FlowCommands PinNumberSubmissionResult
submitPinNumberFlow sub = do 
  pin <- getPinNumberFlow
  setPinNumberSubmissionStatus $ Loading
  handle pin =<< submitPinNumber sub pin
  where 
    handle _ (Left l) = do
      setPinNumberSubmissionStatus $ Failure l
      submitPinNumberFlow sub
    handle pin (Right r) = do
      setPinNumberSubmissionStatus $ Success pin
      pure  r