module Component.Tickets (mkTicketsComponent, TicketProps) where

import Prelude

import Context as Context
import Data.Ticket (Ticket)
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.Events as Event
import React.Basic.Hooks (JSX)
import React.Basic.Hooks as React

type TicketProps
  = { title :: String
    , tickets :: Array Ticket
    , ticketHandler :: Ticket -> Effect Unit
    }

mkTickets :: String -> Array Ticket -> (Ticket -> Effect Unit) -> Array JSX
mkTickets title tickets ticketHandler = [ DOM.h1 { className: "Journey_Text", children: [ DOM.text title ] } ] <> map mkTicket tickets
  where
  mkTicket :: Ticket -> JSX
  mkTicket ticket =
    DOM.div
      { className: "ticket-card"
      , children:
          [ DOM.div { className: "ticket_id", children: [ DOM.text $ show ticket.id ] }
          , DOM.div
              { className: "ticket-content price"
              , children: [ DOM.text $ "£" <> show ticket.price ]
              }
          , mkTicketContent ticket.o_date ticket.o_time ticket.origin_place true
          , DOM.div
              { className: "ticket-content sideways_rocket"
              , children: [ DOM.img { src: "assets/sideways_rocket.svg" } ]
              }
          , mkTicketContent ticket.d_date ticket.d_time ticket.destination_place false
          ]
      , onClick: Event.handler_ (ticketHandler ticket)
      }
    where
    mkTicketContent date time place isSource =
      DOM.div
        { className: "ticket-content " <> if isSource then "source" else "destination"
        , children:
            [ DOM.p { className: "date", children: [ DOM.text date ] }
            , DOM.i { className: "fa fa-clock-o" }
            , DOM.p { className: "time", children: [ DOM.text time ] }
            , DOM.i { className: "fa fa-map-marker" }
            , DOM.p { className: "location", children: [ DOM.text place ] }
            ]
        }

mkTicketsComponent :: Context.Component TicketProps
mkTicketsComponent = do
  Context.component "Tickets" \props -> React.do
    let
      { title, tickets, ticketHandler } = props
    pure $ React.fragment (mkTickets title tickets ticketHandler)
