module Components.AccountPage (mkAccountPageComponent) where

import Prelude
import Component.Tickets (mkTicketsComponent)
import Components.NavBar (mkNavBarComponent)
import Context as Context
import Data.Array (null)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Ticket (Ticket)
import Data.Tuple.Nested ((/\))
import React.Basic.DOM as DOM
import React.Basic.Hooks as React

mkAccountPageComponent :: Context.Component Unit
mkAccountPageComponent = do
  navbar <- mkNavBarComponent
  tickets <- mkTicketsComponent
  Context.component "AccountPage" \_ -> React.do
    person /\ setPerson <- React.useState' Nothing
    let
      mkAccountDetail isLeft name value =
        DOM.div
          { className: "account-details account-" <> (if isLeft then "left" else "right")
          , children:
              [ DOM.strong_ [ DOM.text $ name <> ":" ]
              , DOM.text value
              ]
          }

      accountDetails = case person of
        Nothing -> []
        Just val ->
          [ mkAccountDetail true "First Name" val.first_name
          , mkAccountDetail false "Last Name" val.last_name
          , mkAccountDetail true "Email" val.email
          , mkAccountDetail false "Address" val.adress
          ]

      personalDetails =
        DOM.div
          { className: "personal-details"
          , children:
              [ DOM.div
                  { className: "subheader"
                  , children: [ DOM.text "Personal Details" ]
                  }
              , DOM.div
                  { className: "details-wrapper"
                  , children: accountDetails
                  }
              ]
          }

      purchasedTickets :: Array Ticket
      purchasedTickets = fromMaybe [] $ (\p -> p.tickets) <$> person

      purchasedTicketsDiv =
        if (null purchasedTickets) then
          React.fragment
            [ DOM.h1 { className: "Journey_Text", children: [ DOM.text "Previously purchased tickets" ] }
            , DOM.a { className: "account-link", href: "/", children: [ DOM.text "Book your first flight today." ] }
            ]
        else
          tickets { title: "Purchased Tickets", tickets: purchasedTickets, ticketHandler: \_ -> pure unit }
    pure
      $ DOM.div
          { className: "account-container"
          , children:
              [ navbar { isMainPage: false }
              , DOM.div
                  { className: "account-wrapper"
                  , children:
                      [ DOM.h1 { className: "title-header", children: [ DOM.text "My Account" ] }
                      , personalDetails
                      , purchasedTicketsDiv
                      ]
                  }
              ]
          }
