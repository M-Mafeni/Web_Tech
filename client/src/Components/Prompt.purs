module Components.Prompt (mkPromptComponent, PromptResult, promptFailure, promptSuccess) where

import Prelude

import Data.Maybe (Maybe, fromMaybe, isJust)
import Data.Monoid (guard)
import React.Basic.DOM as DOM
import Router as Router

data PromptResult = Success | Failure

promptSuccess :: PromptResult
promptSuccess = Success

promptFailure :: PromptResult
promptFailure = Failure

isSuccess :: PromptResult -> Boolean
isSuccess (Success) = true
isSuccess _        = false

isFailure :: PromptResult -> Boolean
isFailure = not <<< isSuccess

instance showPromptResult :: Show PromptResult where
  show (Success) = "prompt-success"
  show (Failure) = "prompt-failure"

type PromptProps = {
  prompt:: Maybe String,
  result:: Maybe PromptResult
}

mkPromptComponent :: Router.Component PromptProps
mkPromptComponent = Router.component "Prompt" $ \props -> pure $ guard (isJust props.prompt) $
  DOM.div {
    className: "prompt " <> show (fromMaybe Failure props.result),
    children: [DOM.text $ fromMaybe "" props.prompt]
  }

