module Main (main) where

import Ouisys.Types
import Control.Monad.Free (Free)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Ouisys.Backend.MockApi (mockApi)
import Ouisys.Flows as Flows
import Ouisys.Flows.Interpreters.ConfDepInterpreter (Config, UIConfig, run)
import Ouisys.Flows.Language (FlowCommandsF, setSubscriptionStatus)
import Prelude (Unit, bind, void, ($))

demoPinFlow :: Free FlowCommandsF Unit
demoPinFlow = do 
  phoneNumberSubmission <- Flows.submitPhoneNumberFlow
  pinNumberSubmissionResult <- Flows.submitPinNumberFlow phoneNumberSubmission
  setSubscriptionStatus $ toSubscriptionStatusResult pinNumberSubmissionResult

main :: UIConfig -> Effect Unit
main uiConfig = launchAff_ $ do
  let (config :: Config) = {
      ui: uiConfig
    , api: mockApi
  }
  void $ run config demoPinFlow
