module Ouisys.Types (
  module Ouisys.Types
, module Ouisys.Types.RDS
, module Ouisys.Types.CheckSubscriptionToken
, module Ouisys.Types.PhoneNumberSubmissionResult
, module Ouisys.Types.PinNumberSubmissionResult
, module Ouisys.Types.SubscriptionStatusResult
) where

import Prelude (Unit)
import Data.Either (Either)
import Ouisys.Types.RDS (RDS(..))
import Ouisys.Types.CheckSubscriptionToken (class ToCheckSubscriptionStatusToken, CheckSubscriptionToken(..), toCheckSubscriptionStatusToken)
import Ouisys.Types.PhoneNumberSubmissionResult (PhoneNumberSubmissionResult(..))
import Ouisys.Types.PinNumberSubmissionResult (PinNumberSubmissionResult(..))
import Ouisys.Types.SubscriptionStatusResult (class ToSubscriptionStatusResult, SubscriptionStatusResult(..), toSubscriptionStatusResult)

type Operator = String
type PhoneNumber = String
type PinNumber = String

type GetPinNumberResult = Either Unit PinNumber


