module Ouisys.Flows.Interpreters.ConfDepInterpreter (
  run
, UIConfig
, Config
) where


import Ouisys.Types
import Control.Monad.Free (foldFree)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff, attempt)
import Effect.Class (liftEffect)
import Ouisys.Backend.Api (Api)
import Ouisys.Flows.Language (FlowCommands, FlowCommandsF(..))
import Prelude (type (~>), Unit, discard, pure, unit, ($), (/=), (<), (<$>), (<<<), (=<<))


flowCommandsN :: Config -> FlowCommandsF ~> Aff
flowCommandsN {ui:{getPhoneNumber}} (GetPhoneNumber k) = k <$> (Promise.toAff =<< liftEffect getPhoneNumber)
flowCommandsN {ui:{getPinNumber}} (GetPinNumber _ k) = k <$> (handle <$> attempt (Promise.toAff =<< liftEffect getPinNumber))
  where 
    handle (Left _) = Left unit
    handle (Right p) = Right p
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
flowCommandsN {api} (CheckSubscriptionStatus token k) = k <$> (pure $ Left "Not implemented")
flowCommandsN {ui} (SetSubscriptionStatus (SubscriptionStatusResult v) k) = do 
  liftEffect $ ui.setSubscriptionStatus $ encodeJson v
  pure k

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
  , setSubscriptionStatus :: Json -> Effect Unit
}

