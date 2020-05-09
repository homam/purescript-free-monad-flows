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
flowCommandsN _ (SubmitPhoneNumber v k) = k <$> do 
  delay (Milliseconds 1000.0)
  let indexOf0 = fromMaybe (-1) (String.indexOf (String.Pattern "0") v ) 
  if indexOf0 /= 0 then
    pure $ Left $ "Server Error: " <> v <> " must start with 0."
  else
    pure $ Right unit
flowCommandsN _ (ValidatePinNumber v k) = k <$> do
  if String.length v < 4 then
    pure $ Left "Pin number must be greater than four digits."
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
    void $ Flows.submitPhoneNumberFlow
    Flows.getPinNumberFlow
  -- liftEffect $ log a
