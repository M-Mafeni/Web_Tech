module Components.ConfirmationPage (mkConfirmationPageComponent) where

import Prelude
import Context as Context
import React.Basic.DOM as DOM

mkConfirmationPageComponent :: Context.Component Unit
mkConfirmationPageComponent =
  Context.component "ConfirmationPage" \_ ->
    pure $ DOM.h1_ [ DOM.text "Confirmation Page" ]
