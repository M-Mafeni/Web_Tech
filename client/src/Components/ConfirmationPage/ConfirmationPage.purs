module Components.ConfirmationPage (mkConfirmationPageComponent, ConfirmationPageProps) where

import Prelude
import Component.Tickets (mkTicketsComponent)
import Components.NavBar (mkNavBarComponent)
import Context as Context
import Data.Maybe (fromMaybe)
import Data.Monoid (guard)
import Data.Ticket (Ticket)
import Data.Tuple.Nested ((/\))
import Effect.Console (log, logShow)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (targetValue)
import React.Basic.Events as Event
import React.Basic.Hooks as React

type ConfirmationPageProps
  = { inboundTicket :: Ticket
    , outboundTicket :: Ticket
    }

mkConfirmationPageComponent :: Context.Component ConfirmationPageProps
mkConfirmationPageComponent = do
  navbar <- mkNavBarComponent
  tickets <- mkTicketsComponent
  Context.component "ConfirmationPage" \props -> React.do
    React.useEffectOnce do
      log "Inbound Ticket"
      logShow props.inboundTicket
      log "Outbound Ticket"
      logShow props.inboundTicket
      pure mempty
    showPayButton /\ setShowPayButton <- React.useState' false
    let
      paymentSelect =
        DOM.select
          { id: "payment"
          , children:
              [ DOM.option { value: "Select Card", children: [ DOM.text "Select Card" ] }
              , DOM.option { value: "card", children: [ DOM.text "Visa Debit ending 1234" ] }
              ]
          , onChange:
              Event.handler (targetValue) \s -> do
                let
                  val = fromMaybe "" s
                setShowPayButton (val /= "Select Card")
          }

      hiddenFormDiv =
        DOM.div
          { className: "hidden-form"
          , children:
              [ DOM.input { type: "number", name: "source_id", defaultValue: show props.outboundTicket.id }
              , DOM.input { type: "number", name: "dest_id", defaultValue: show props.inboundTicket.id }
              ]
          }
    pure
      $ React.fragment
          [ navbar { isMainPage: false }
          , DOM.div
              { className: "confirmation-container"
              , children:
                  [ DOM.div
                      { className: "confirmed_tickets"
                      , children: [ tickets { title: "Confirm your booking", tickets: [ props.outboundTicket, props.inboundTicket ], ticketHandler: (const (pure unit)), isAccount: false } ]
                      }
                  , DOM.p
                      { id: "total-price"
                      , children: [ DOM.text $ "Total: " <> (show $ props.inboundTicket.price + props.outboundTicket.price) ]
                      }
                  , DOM.form
                      { action: "/confirmed"
                      , method: "post"
                      , className: "confirm-form"
                      , children:
                          [ paymentSelect
                          , hiddenFormDiv
                          , guard showPayButton DOM.input { type: "submit", id: "payButton", className: "btn-pay-now", defaultValue: "Pay now" }
                          ]
                      }
                  ]
              }
          ]
