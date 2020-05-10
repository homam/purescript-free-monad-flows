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
import Prelude (type (~>), Unit, pure, unit, ($), (/=), (<), (<$>), (<*), (<<<), (=<<))

-- | Natural transformation of `FlowCommandsF` to `Aff` monad.
-- This function hands over UI or API functionalities to dependencies that are injected by `config` param.
-- `Config` has two fields: `{ui, api}`.
-- This means you can the `ui` or `api` of your choice.
flowCommandsN :: Config -> FlowCommandsF ~> Aff
flowCommandsN {ui} (GetPhoneNumber next) = next <$> do 
  Promise.toAff =<< liftEffect ui.getPhoneNumber
flowCommandsN {ui} (GetPinNumber _ next) = next <$> 
  do handle <$> attempt (Promise.toAff =<< liftEffect ui.getPinNumber)
  where 
    handle (Left _) = Left unit
    handle (Right p) = Right p
flowCommandsN {ui} (SetPhoneNumberSubmissionStatus v next) = pure next <* do
  liftEffect $ ui.setPhoneNumberSubmissionResult $ encodeJson v
flowCommandsN {ui} (SetPinNumberSubmissionStatus v next) = pure next <* do
  liftEffect $ ui.setPinNumberSubmissionResult $ encodeJson v
flowCommandsN _ (ValidatePhoneNumber v next) = next <$> do
  if String.length v /= 8 then
    pure $ Left "Phone number must have exactly 8 digits"
  else
    pure $ Right unit
flowCommandsN {api} (SubmitPhoneNumber phone next) = next <$> api.submitPhoneNumber {phone}
flowCommandsN _ (ValidatePinNumber pin next) = next <$> do
  if String.length pin < 4 then
    pure $ Left "Pin number must be greater than four digits."
  else
    pure $ Right unit
flowCommandsN {api} (SubmitPinNumber sub pin next) = next <$> api.submitPinNumber {phoneNumberSubmissionResult: sub, pin}
flowCommandsN {api} (CheckSubscriptionStatus token next) = next <$> do 
  pure $ Left "Not implemented"
flowCommandsN {ui} (SetSubscriptionStatus (SubscriptionStatusResult v) next) = pure next <* do
  liftEffect $ ui.setSubscriptionStatus $ encodeJson v
flowCommandsN {api} (GetClickToSMSDetails next)  = next <$> api.getClickToSMSDetails
flowCommandsN _ (ClickToSMS details next)  = pure next 

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

