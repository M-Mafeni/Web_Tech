module Components.Prompt (mkPromptComponent, PromptResult(..), promptFailure, promptSuccess) where

import Prelude

import Context as Context
import Data.Maybe (Maybe, fromMaybe, isJust)
import Data.Monoid (guard)
import React.Basic.DOM as DOM

data PromptResult = Success | Failure

promptSuccess :: PromptResult
promptSuccess = Success

promptFailure :: PromptResult
promptFailure = Failure

instance showPromptResult :: Show PromptResult where
  show (Success) = "prompt-success"
  show (Failure) = "prompt-fail"

type PromptProps = {
  prompt:: Maybe String,
  result:: Maybe PromptResult
}

mkPromptComponent :: Context.Component PromptProps
mkPromptComponent = Context.component "Prompt" $ \props -> pure $ guard (isJust props.prompt) $
  DOM.div {
    className: "prompt " <> show (fromMaybe Failure props.result),
    children: [DOM.text $ fromMaybe "" props.prompt]
  }

