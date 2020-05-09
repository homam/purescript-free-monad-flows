module Teletype where

import Prelude

import Control.Monad.Free (Free, foldFree, liftF)
import Control.Promise as Promise
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)

foreign import getLineUI :: Effect (Promise.Promise String)

data TeletypeF a = PutStrLn String a | GetLine (String -> a)
derive instance functorTeletypeF :: Functor TeletypeF


type Teletype a = Free TeletypeF a

putStrLn :: String -> Teletype Unit
putStrLn s = liftF (PutStrLn s unit)

getLine :: Teletype String
getLine = liftF (GetLine identity)

teletypeN :: TeletypeF ~> Aff
teletypeN (PutStrLn s k) = liftEffect (log s) *> pure k 
teletypeN (GetLine k) = k <$> (do 
    l <- Promise.toAff =<< liftEffect getLineUI
    delay (Milliseconds 1500.0)
    pure l
  )


run :: Teletype ~> Aff
run = foldFree teletypeN

echo :: Teletype String
echo = do
  a <- getLine
  putStrLn a
  putStrLn "Finished"
  pure $ "EOF"


main :: Effect Unit
main = launchAff_ $ do
  a <- run echo
  liftEffect $ log a

---

wait :: ∀ u. Number → Aff u → Aff u
wait n f = delay (Milliseconds n) *> f