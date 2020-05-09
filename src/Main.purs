module Main (main) where

import Ouisys.Flows.FlowCommands
import Prelude

import Control.Monad.Free (Free, foldFree, liftF)
import Control.Promise as Promise
import Data.Argonaut.Core (Json, stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..), either)
import Data.Maybe (fromMaybe, maybe)
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Ouisys.Flows as Flows


flowCommandsN :: Config -> FlowCommandsF ~> Aff
flowCommandsN {uiGetPhoneNumber} (GetPhoneNumber k) = k <$> (Promise.toAff =<< liftEffect uiGetPhoneNumber)
flowCommandsN {uiGetPinNumber} (GetPinNumber k) = k <$> (Promise.toAff =<< liftEffect uiGetPinNumber)
flowCommandsN {uiSetPhoneNumberSubmissionResult} (SetPhoneNumberSubmissionStatus v k) = do
  liftEffect $ uiSetPhoneNumberSubmissionResult $ handle v
  pure k
  where
    handle rds =  (encodeJson rds)
flowCommandsN {uiSetPinNumberSubmissionResult} (SetPinNumberSubmissionStatus v k) = do
  liftEffect $ uiSetPinNumberSubmissionResult $ handle v
  pure k
  where
    handle rds =  (encodeJson rds)
flowCommandsN _ (ValidatePhoneNumber v k) = k <$> do
  if String.length v /= 8 then
    pure $ Left "Phone number must have exactly 8 digits"
  else
    pure $ Right unit
flowCommandsN _ (SubmitPhoneNumber phone k) = k <$> do 
  delay (Milliseconds 1000.0)
  let indexOf0 = fromMaybe (-1) (String.indexOf (String.Pattern "0") phone ) 
  if indexOf0 /= 0 then
    pure $ Left $ "Server Error: " <> phone <> " must start with 0."
  else
    pure $ Right $ PhoneNumberSubmissionResult {}
flowCommandsN _ (ValidatePinNumber pin k) = k <$> do
  if String.length pin < 4 then
    pure $ Left "Pin number must be greater than four digits."
  else
    pure $ Right unit
flowCommandsN _ (SubmitPinNumber sub pin k) = k <$> do 
  delay (Milliseconds 1000.0)
  let indexOf0 = fromMaybe (-1) (String.indexOf (String.Pattern "0000") pin ) 
  if indexOf0 /= 0 then
    pure $ Left "Server Error: Pin is 0000"
  else
    pure $ Right unit

run :: Config -> FlowCommands ~> Aff
run = foldFree <<< flowCommandsN


type Config = {
    uiGetPhoneNumber :: Effect (Promise.Promise String)
  , uiSetPhoneNumberSubmissionResult :: Json -> Effect Unit
  , uiGetPinNumber :: Effect (Promise.Promise String)
  , uiSetPinNumberSubmissionResult :: Json -> Effect Unit
}



main :: Config -> Effect Unit
main config = launchAff_ $ do
  void $ run config $ do 
    phoneNumberSubmission <- Flows.submitPhoneNumberFlow
    Flows.submitPinNumberFlow phoneNumberSubmission
  -- liftEffect $ log a
