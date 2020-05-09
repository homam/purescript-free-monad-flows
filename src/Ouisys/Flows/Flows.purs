module Ouisys.Flows where

import Ouisys.Flows.FlowCommands
import Prelude

import Data.Either (Either(..), either)
import Data.String as String

submitPhoneNumberFlow :: FlowCommands (Either String Unit)
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
      pure $ Right r
  

getPhoneNumberFlow :: FlowCommands PhoneNumber
getPhoneNumberFlow = do 
  phone <- getPhoneNumber
  handle phone =<< validatePhoneNumber phone
  where 
    handle _ (Left error) = do
      setPhoneNumberSubmissionStatus $ Failure error
      getPhoneNumberFlow
    handle phone (Right _) = pure phone


getPinNumberFlow :: FlowCommands PinNumber
getPinNumberFlow = do 
  pin <- getPinNumber
  handle pin =<< validatePinNumber pin
  where 
    handle _ (Left error) = do
      setPinNumberSubmissionStatus $ Failure error
      getPinNumberFlow
    handle pin (Right _) = pure pin
      