module Ouisys.Flows where

import Ouisys.Flows.Language (FlowCommands, getPhoneNumber, getPinNumber, setPhoneNumberSubmissionStatus, setPinNumberSubmissionStatus, submitPhoneNumber, submitPinNumber, validatePhoneNumber, validatePinNumber)
import Data.Either (Either(..), either)
import Ouisys.Types (PhoneNumber, PhoneNumberSubmissionResult, PinNumber, PinNumberSubmissionResult, RDS(..))
import Prelude (bind, const, discard, pure, ($), (=<<), (>>=)) 

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


getPinNumberFlow :: PhoneNumberSubmissionResult -> FlowCommands PinNumber
getPinNumberFlow sub = do 
  pin <- handleGetPin =<< getPinNumber sub
  handle pin =<< validatePinNumber pin
  where 
    handleGetPin = either
      (const $ submitPhoneNumberFlow >>= getPinNumberFlow)
      pure 
    handle _ (Left error) = do
      setPinNumberSubmissionStatus $ Failure error
      getPinNumberFlow sub
    handle pin (Right _) = pure pin
      
submitPinNumberFlow :: PhoneNumberSubmissionResult -> FlowCommands PinNumberSubmissionResult
submitPinNumberFlow sub = do 
  pin <- getPinNumberFlow sub
  setPinNumberSubmissionStatus Loading
  handle pin =<< submitPinNumber sub pin
  where 
    handle _ (Left l) = do
      setPinNumberSubmissionStatus $ Failure l
      submitPinNumberFlow sub
    handle pin (Right r) = do
      setPinNumberSubmissionStatus $ Success pin
      pure  r