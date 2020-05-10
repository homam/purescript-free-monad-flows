module Main (main) where

import Ouisys.Flows.Language (FlowCommands, FlowCommandsF(..))
import Prelude (type (~>), Unit, bind, discard, pure, unit, void, ($), (/=), (<), (<$>), (<<<), (=<<))
import Control.Monad.Free (foldFree)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Ouisys.Flows as Flows
import Ouisys.Backend.MockApi (mockApi, Api)



flowCommandsN :: Config -> FlowCommandsF ~> Aff
flowCommandsN {ui:{getPhoneNumber}} (GetPhoneNumber k) = k <$> (Promise.toAff =<< liftEffect getPhoneNumber)
flowCommandsN {ui:{getPinNumber}} (GetPinNumber k) = k <$> (Promise.toAff =<< liftEffect getPinNumber)
flowCommandsN {ui:{setPhoneNumberSubmissionResult}} (SetPhoneNumberSubmissionStatus v k) = do
  liftEffect $ setPhoneNumberSubmissionResult $ encodeJson v
  pure k
flowCommandsN {ui:{setPinNumberSubmissionResult}} (SetPinNumberSubmissionStatus v k) = do
  liftEffect $ setPinNumberSubmissionResult $ encodeJson v
  pure k
flowCommandsN _ (ValidatePhoneNumber v k) = k <$> do
  if String.length v /= 8 then
    pure $ Left "Phone number must have exactly 8 digits"
  else
    pure $ Right unit
flowCommandsN {api} (SubmitPhoneNumber phone k) = k <$> (api.submitPhoneNumber {phone})
flowCommandsN _ (ValidatePinNumber pin k) = k <$> do
  if String.length pin < 4 then
    pure $ Left "Pin number must be greater than four digits."
  else
    pure $ Right unit
flowCommandsN {api} (SubmitPinNumber sub pin k) = k <$> (api.submitPinNumber {phoneNumberSubmissionResult: sub, pin})

run :: Config -> FlowCommands ~> Aff
run = foldFree <<< flowCommandsN

type Config = {
    ui :: UIConfig
  , api :: Api
}

type UIConfig = {
    getPhoneNumber :: Effect (Promise.Promise String)
  , setPhoneNumberSubmissionResult :: Json -> Effect Unit
  , getPinNumber :: Effect (Promise.Promise String)
  , setPinNumberSubmissionResult :: Json -> Effect Unit
}



main :: UIConfig -> Effect Unit
main uiConfig = launchAff_ $ do
  let (config :: Config) = {
      ui: uiConfig
    , api: mockApi
  }
  void $ run config $ do 
    phoneNumberSubmission <- Flows.submitPhoneNumberFlow
    Flows.submitPinNumberFlow phoneNumberSubmission
  -- liftEffect $ log a
