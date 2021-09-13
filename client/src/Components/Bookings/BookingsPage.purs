module Components.BookingsPage (mkBookingsPageComponent) where

import Prelude

import Component.Tickets (mkTicketsComponent)
import Components.ConfirmationPage (mkConfirmationPageComponent)
import Components.NavBar (mkNavBarComponent)
import Components.Spinner (mkSpinner)
import Context as Context
import Control.Monad.Reader (ask)
import Data.Array (null)
import Data.BookingsSearch (BookingsSearch, getBookingTickets)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), isJust, isNothing)
import Data.Monoid (guard)
import Data.Ticket (Ticket)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (runAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (preventDefault)
import React.Basic.Events as Event
import React.Basic.Hooks (JSX)
import React.Basic.Hooks as React

mobileSummaryBlock :: (Maybe Ticket) -> (Maybe Ticket) -> Boolean -> ((Boolean -> Boolean) -> Effect Unit) -> (Boolean -> Effect Unit) -> JSX
mobileSummaryBlock finalOutboundTicket finalInboundTicket showMobileDetail setShowMobileDetail setIsConfirmationPage =
  DOM.div
    { className: "summary-icon"
    , children:
        [ DOM.span
            { id: "summary-title-mobile"
            , children: [ DOM.text $ if (isNothing finalOutboundTicket && isNothing finalInboundTicket) then "No ticket selected" else "Summary" ]
            }
        , guard (isJust finalOutboundTicket || isJust finalInboundTicket) DOM.i
            { className: if (showMobileDetail) then "fa fa-angle-double-down" else "fa fa-angle-double-up"
            , onClick: Event.handler_ (setShowMobileDetail not)
            }
        , DOM.div { id: "summary_price_mobile_final", children: [ DOM.text finalPriceText ] }
        , DOM.div
            { className: "sumary-mobile"
            , id: "mobile_summary"
            , children: mkOutboundTicketDetails
            }
        , DOM.div
            { className: "sumary-mobile"
            , id: "d_mobile_summary"
            , children: mkInboundTicketDetails
            }
        , guard (isJust finalOutboundTicket && isJust finalInboundTicket) DOM.button
            { className: "btn continue-mobile"
            , children: [ DOM.text "Continue" ]
            , onClick:
                Event.handler_ do
                  case (finalOutboundTicket /\ finalInboundTicket) of
                    Just _ /\ Just _ -> setIsConfirmationPage true
                    _ -> pure unit
            }
        ]
    }
  where
  finalPriceText = case (finalOutboundTicket /\ finalInboundTicket) of
    (Nothing /\ Nothing) -> ""
    (Just t1 /\ Just t2) -> "£" <> (show $ t1.price + t2.price)
    (Just t1 /\ Nothing) -> "£" <> show t1.price
    (Nothing /\ Just t2) -> "£" <> show t2.price

  mkInboundTicketDetails = case finalInboundTicket of
    Nothing -> [ DOM.div { id: "d_summary_price_mobile", className: "summary_price_mobile", children: [ DOM.text "No inbound ticket selected" ] } ]
    Just ticket ->
      [ DOM.div { id: "d_summary_price_mobile", className: "summary_price_mobile", children: [ DOM.text $ "£" <> (show ticket.price) ] }
      , guard showMobileDetail $ summaryDetails false ticket
      ]

  mkOutboundTicketDetails = case finalOutboundTicket of
    Nothing ->
      [ DOM.div
          { id: "summary_price_mobile"
          , className: "summary_price_mobile"
          , children: [ DOM.text "No outbound ticket selected" ]
          }
      ]
    Just ticket ->
      [ DOM.div { id: "d_summary_price_mobile", className: "summary_price_mobile", children: [ DOM.text $ "£" <> (show ticket.price) ] }
      , guard showMobileDetail $ summaryDetails true ticket
      ]

  summaryDetails isOutbound ticket = mkSummaryDetails true <> mkSummaryDetails false
    where
    mkSummaryDetails isSource =
      DOM.div
        { className: "summary_details_mobile_" <> classNameSuffix
        , children:
            [ DOM.div
                { className: "date " <> prefix <> "Date"
                , children: [ DOM.text (if isSource then ticket.o_date else ticket.d_date) ]
                }
            , DOM.span
                { className: "time " <> prefix <> "Time"
                , children: [ DOM.text (if isSource then ticket.o_time else ticket.d_time) ]
                }
            , DOM.div
                { className: "location " <> prefix <> "Location"
                , children: [ DOM.text (if isSource then ticket.origin_place else ticket.destination_place) ]
                }
            ]
        }
      where
      prefix = if isSource then "departure" else "arrival"

      classNameSuffix =
        (if isSource then "source" else "destination")
          <> " "
          <> (if isOutbound then "summary_outbound" else "summary_inbound")

hiddenForm :: Ticket -> Ticket -> (Boolean -> Effect Unit) -> JSX
hiddenForm finalOutboundTicket finalInboundTicket setIsConfirmationPage =
  DOM.form
    { id: "hidden-form"
    , action: "/confirmation"
    , method: "POST"
    , children:
        [ DOM.div
            { className: "hidden-form"
            , children: (f true finalOutboundTicket) <> (f false finalInboundTicket)
            }
        , DOM.button
            { type: "submit"
            , name: "continue"
            , className: "btn"
            , children: [ DOM.text "Continue" ]
            }
        ]
    , onSubmit: Event.handler preventDefault \_ -> setIsConfirmationPage true
    }
  where
  mkInput (name /\ value) = DOM.input { type: "text", name, value, readOnly: true }

  f isOutbound ticket =
    map (mkInput <<< \(name /\ x) -> (((if isOutbound then "out_" else "in_") <> name) /\ x))
      [ "id" /\ (show ticket.id)
      , "price" /\ (show ticket.price)
      , "o_date" /\ ticket.o_date
      , "o_time" /\ ticket.o_time
      , "o_loc" /\ ticket.origin_place
      , "d_date" /\ ticket.d_date
      , "d_time" /\ ticket.d_time
      , "d_loc" /\ ticket.destination_place
      ]

summaryBlock :: (Maybe Ticket) -> (Maybe Ticket) -> (Boolean -> Effect Unit) -> JSX
summaryBlock finalOutboundTicket finalInboundTicket setIsConfirmationPage =
  DOM.div
    { className: "column summary"
    , id: "summary"
    , children:
        [ DOM.h1_ [ DOM.text "Summary" ]
        , DOM.div { id: "summary_price_final", children: [ DOM.text finalPriceText ] }
        , mkOutboundTicketDetails
        , mkInboundTicketDetails
        , hiddenFormVal
        ]
    }
  where
  finalPriceText = case (finalOutboundTicket /\ finalInboundTicket) of
    (Nothing /\ Nothing) -> ""
    (Just t1 /\ Just t2) -> "£" <> (show $ t1.price + t2.price)
    (Just t1 /\ Nothing) -> "£" <> show t1.price
    (Nothing /\ Just t2) -> "£" <> show t2.price

  hiddenFormVal = case (finalOutboundTicket /\ finalInboundTicket) of
    (Just t1 /\ Just t2) -> hiddenForm t1 t2 setIsConfirmationPage
    _ -> mempty

  mkInboundTicketDetails = case finalInboundTicket of
    Nothing ->
      DOM.p
        { className: "d_unselected"
        , children: [ DOM.text "No inbound ticket selected" ]
        }
    Just ticket -> mkSummaryDetails true ticket

  mkOutboundTicketDetails = case finalOutboundTicket of
    Nothing ->
      DOM.p
        { className: "o_unselected"
        , children: [ DOM.text "No outbound ticket selected" ]
        }
    Just ticket -> mkSummaryDetails false ticket

  mkSummaryDetails isInbound ticket =
    React.fragment
      [ DOM.div { id: "summary_price", className: "summary_price", children: [ DOM.text $ "£" <> (show ticket.price) ] }
      , DOM.div
          { id: (guard isInbound "d_") <> "summary_details"
          , className: "summary_details change_height"
          , children: mkDetails true <> mkDetails false
          }
      ]
    where
    mkDetails isDeparture =
      let
        prefix = if isDeparture then "departure" else "arrival"
      in
        [ DOM.div
            { id: guard (not isDeparture) "arrivalDate"
            , className: "date " <> prefix <> "Date"
            , children: [ DOM.text (if isDeparture then ticket.d_date else ticket.o_date) ]
            }
        , DOM.span
            { className: "time " <> prefix <> "Time"
            , children: [ DOM.text $ (if isDeparture then ticket.d_time else ticket.o_time) <> " " ]
            }
        , DOM.span
            { className: "location " <> prefix <> "Location"
            , children: [ DOM.text (if isDeparture then ticket.destination_place else ticket.origin_place) ]
            }
        ]

mkBookingsPageComponent :: Context.Component BookingsSearch
mkBookingsPageComponent = do
  navbar <- mkNavBarComponent
  spinner <- liftEffect mkSpinner
  tickets <- mkTicketsComponent
  confirmationPage <- mkConfirmationPageComponent
  Context.component "Bookings" \bookingsSearch -> React.do
    let
      noTickets = DOM.p_ [ DOM.text "No tickets available for this journey" ]
    outboundTickets /\ setOutboundTickets <- React.useState' []
    inboundTickets /\ setInboundTickets <- React.useState' []
    finalOutboundTicket /\ setFinalOutboundTicket <- React.useState' Nothing
    finalInboundTicket /\ setFinalInboundTicket <- React.useState' Nothing
    showMobileDetail /\ setShowMobileDetail <- React.useState false
    isLoading /\ setIsLoading <- React.useState' true
    isConfirmationPage /\ setIsConfirmationPage <- React.useState' false
    React.useEffectOnce do
      flip runAff_ (getBookingTickets bookingsSearch) \res -> case res of
        Left err -> throwError err
        Right possTickets -> case possTickets of
          Left err -> throw err
          Right { outboundTickets: oTickets, inboundTickets: iTickets } -> do
            setOutboundTickets oTickets
            setInboundTickets iTickets
            setIsLoading false
      pure mempty
    let
      columnTickets =
        DOM.div
          { className: "column tickets"
          , children:
              [ DOM.div
                  { id: "outbound"
                  , children: [ tickets { title: "Outbound Journeys", tickets: outboundTickets, ticketHandler: Just >>> setFinalOutboundTicket } ]
                  }
              , if null inboundTickets then
                  noTickets
                else
                  DOM.div
                    { id: "inbound"
                    , children: [ tickets { title: "Inbound Journeys", tickets: inboundTickets, ticketHandler: Just >>> setFinalInboundTicket } ]
                    }
              ]
          }
    pure
      if isConfirmationPage then
        case finalInboundTicket /\ finalOutboundTicket of
          Just inboundTicket /\ Just outboundTicket -> confirmationPage {inboundTicket, outboundTicket}
          _  -> DOM.text "Error: 1 ticket wasnt't set before confirmation"
      else
        DOM.div
            { className: "bookings-container"
            , children:
                [ navbar { isMainPage: false }
                , if isLoading then
                    spinner
                  else
                    React.fragment
                      [ mobileSummaryBlock finalOutboundTicket finalInboundTicket showMobileDetail setShowMobileDetail setIsConfirmationPage
                      , DOM.div
                          { className: "row"
                          , children:
                              if null outboundTickets then
                                [ noTickets ]
                              else
                                [ columnTickets
                                , DOM.span { id: "summaryTop" }
                                , summaryBlock finalOutboundTicket finalInboundTicket setIsConfirmationPage
                                ]
                          }
                      ]
                ]
            }
