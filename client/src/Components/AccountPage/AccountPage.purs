module Components.AccountPage (mkAccountPageComponent) where

import Prelude

import Component.Tickets (mkTicketsComponent)
import Components.NavBar (mkNavBarComponent)
import Components.Spinner (mkSpinner)
import Context as Context
import Data.Array (null)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Ticket (Ticket)
import Data.Tuple.Nested ((/\))
import Data.User (getCurrentUser)
import Effect.Aff (killFiber, launchAff_, runAff)
import Effect.Class (liftEffect)
import Effect.Exception (error, throw) as Exception
import React.Basic.DOM as DOM
import React.Basic.Hooks as React

mkAccountPageComponent :: Context.Component Unit
mkAccountPageComponent = do
  navbar <- mkNavBarComponent
  tickets <- mkTicketsComponent
  spinner <- liftEffect mkSpinner
  Context.component "AccountPage" \_ -> React.do
    person /\ setPerson <- React.useState' Nothing
    isLoading /\ setIsLoading <- React.useState' true
    React.useEffectOnce do
      fiber <- flip runAff getCurrentUser \val -> case val of 
        Left err -> Exception.throw $ show err 
        Right possJson -> case possJson of
          Left err -> Exception.throw err
          Right userJson -> do 
            setPerson $ Just userJson
            setIsLoading false
      pure $ launchAff_ $ killFiber (Exception.error "Canceled") fiber
    let
      accountSpinner = DOM.div {className: "account-spinner", children: [spinner]}
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
          , mkAccountDetail false "Address" val.address
          ]

      personalDetails =
        DOM.div
          { className: "personal-details"
          , children:
              [ DOM.div
                  { className: "subheader"
                  , children: [ DOM.text "Personal Details" ]
                  }
              , if isLoading then accountSpinner else DOM.div
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
            [ DOM.h1 { className: "Journey_Text", children: [ DOM.text "Purchased tickets" ] }
            , if isLoading then accountSpinner else DOM.a { className: "account-link", href: "/", children: [ DOM.text "Book your first flight today." ] }
            ]
        else
          tickets { title: "Purchased Tickets", tickets: purchasedTickets, ticketHandler: \_ -> pure unit, isAccount: true }
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
