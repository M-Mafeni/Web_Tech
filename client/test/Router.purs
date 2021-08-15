module Test.Router where

import Prelude

import Data.Either (fromRight)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Router.Parser (prettyPrint, spaceRoutes)
import Routing (match)
import Test.QuickCheck (quickCheck, (<?>))

runRouterTests :: Effect Unit
runRouterTests = do
  quickCheck \route ->
    let 
      path = prettyPrint route
      parsedRoute = fromRight Nothing $ match spaceRoutes path
      errMessage = "Orignal Route: " <> show route <> "\n" <>
        "Path: " <> path <> "\n" <>
        "Value Gotten: " <> show parsedRoute
    in eq (Just route) parsedRoute <?> errMessage