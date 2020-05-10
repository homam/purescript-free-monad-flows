module Ouisys.Types.PinNumberSubmissionResult 

where


import Ouisys.Types.CheckSubscriptionToken (class ToCheckSubscriptionStatusToken, CheckSubscriptionToken(..))
import Ouisys.Types.SubscriptionStatusResult (class ToSubscriptionStatusResult, SubscriptionStatusResult(..))

newtype PinNumberSubmissionResult = PinNumberSubmissionResult {}

instance pinNumberSubmissionResultToSubscriptionStatusResult :: ToSubscriptionStatusResult PinNumberSubmissionResult where
  toSubscriptionStatusResult _ = SubscriptionStatusResult {}

instance toCheckSubscriptionStatusTokenPinNumberSubmissionResult :: ToCheckSubscriptionStatusToken PinNumberSubmissionResult where
  toCheckSubscriptionStatusToken _ = CheckSubscriptionToken {}