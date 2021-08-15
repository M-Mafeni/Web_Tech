module Test.Main where

import Prelude

import Effect (Effect)
import Test.ConfirmationPage (runConfirmationPageTests)
import Test.Router (runRouterTests)

main :: Effect Unit
main = do
  runRouterTests
  runConfirmationPageTests
