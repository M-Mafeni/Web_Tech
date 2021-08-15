module Components.ConfirmationPage (mkConfirmationPageComponent, ConfirmationPageProps) where

import Prelude
import Context as Context
import Data.Ticket (Ticket)
import Effect.Console (log, logShow)
import React.Basic.DOM as DOM
import React.Basic.Hooks as React

type ConfirmationPageProps
  = { inboundTicket :: Ticket
    , outboundTicket :: Ticket
    }

mkConfirmationPageComponent :: Context.Component ConfirmationPageProps
mkConfirmationPageComponent =
  Context.component "ConfirmationPage" \props -> React.do
    React.useEffectOnce do
      log "Inbound Ticket"
      logShow props.inboundTicket
      log "Outbound Ticket"
      logShow props.inboundTicket
      pure mempty
    pure $ DOM.h1_ [ DOM.text "Confirmation Page" ]
