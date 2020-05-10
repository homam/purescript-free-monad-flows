module Ouisys.Types.CheckSubscriptionToken where

newtype CheckSubscriptionToken = CheckSubscriptionToken {}

class ToCheckSubscriptionStatusToken a where
  toCheckSubscriptionStatusToken :: a -> CheckSubscriptionToken