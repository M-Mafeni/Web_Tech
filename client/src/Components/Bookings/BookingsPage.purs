module Components.BookingsPage (mkBookingsPageComponent) where

import Prelude
import Components.NavBar (mkNavBarComponent)
import Context as Context
import Data.Array (null)
import Data.BookingsSearch (BookingsSearch, getBookingTickets)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Monoid (guard)
import Data.Ticket (Ticket)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (runAff_, throwError)
import Effect.Exception (throw)
import Prim.TypeError (class Warn, Text)
import React.Basic.DOM as DOM
import React.Basic.Events as Event
import React.Basic.Hooks (JSX)
import React.Basic.Hooks as React

mobileSummaryBlock :: (Warn (Text "Add setTicket functionality in Mobile Summary Block")) => JSX
mobileSummaryBlock =
  DOM.div
    { className: "summary-icon"
    , children:
        [ DOM.span
            { id: "summary-title-mobile"
            , children: [ DOM.text "No ticket selected" ]
            }
        , DOM.i { className: "fa fa-angle-double-down disable-fa" }
        , DOM.i { className: "fa fa-angle-double-up disable-fa" }
        , DOM.div { id: "summary_price_mobile_final" }
        , DOM.div
            { className: "sumary-mobile"
            , id: "mobile_summary"
            , children:
                [ DOM.div { id: "summary_price_mobile", className: "summary_price_mobile", children: [ DOM.text "No outbound ticket selected" ] }
                , summaryDetails true
                ]
            }
        , DOM.div
            { className: "sumary-mobile"
            , id: "d_mobile_summary"
            , children:
                [ DOM.div { id: "d_summary_price_mobile", className: "summary_price_mobile", children: [ DOM.text "No inbound ticket selected" ] }
                , summaryDetails false
                ]
            }
        , DOM.button
            { type: "submit"
            , className: "btn continue-mobile no-continue"
            , children: [ DOM.text "Continue" ]
            }
        ]
    }
  where
  summaryDetails isOutbound = mkSummaryDetails true <> mkSummaryDetails false
    where
    mkSummaryDetails isSource =
      DOM.div
        { className: "summary_details_mobile_" <> classNameSuffix
        , children:
            [ DOM.div
                { className: "date " <> prefix <> "Date"
                }
            , DOM.span
                { className: "time " <> prefix <> "Time"
                }
            , DOM.div
                { className: "location " <> prefix <> "Location"
                }
            ]
        }
      where
      prefix = if isSource then "departure" else "arrival"

      classNameSuffix =
        (if isSource then "source" else "destination")
          <> " "
          <> (if isOutbound then "summary_outbound" else "summary_inbound")

hiddenForm :: JSX
hiddenForm =
  DOM.div
    { className: "hidden-form"
    , children: f true <> f false
    }
  where
  mkInput name = DOM.input { type: "text", name }

  f isOutbound =
    map (mkInput <<< \name -> (if isOutbound then "out_" else "in_") <> name)
      [ "id"
      , "price"
      , "o_date"
      , "o_time"
      , "o_loc"
      , "d_date"
      , "d_time"
      , "d_loc"
      ]

summaryBlock :: (Maybe Ticket) -> (Maybe Ticket) -> JSX
summaryBlock finalOutboundTicket finalInboundTicket =
  DOM.div
    { className: "column summary"
    , id: "summary"
    , children:
        [ DOM.h1_ [ DOM.text "Summary" ]
        , DOM.div { id: "summary_price_final", children: [ DOM.text finalPriceText ] }
        , mkOutboundTicketDetails
        , mkInboundTicketDetails
        , hiddenForm
        ]
    }
  where
  finalPriceText = case (finalOutboundTicket /\ finalInboundTicket) of
    (Nothing /\ Nothing) -> ""
    (Just t1 /\ Just t2) ->  "£" <> (show $ t1.price + t2.price)
    (Just t1 /\ Nothing) -> "£" <> show t1.price
    (Nothing /\ Just t2) -> "£" <> show t2.price

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

mkTickets :: String -> Array Ticket -> (Maybe Ticket -> Effect Unit) -> Array JSX
mkTickets title tickets setFinalTicket = [ DOM.h1 { className: "Journey_Text", children: [ DOM.text title ] } ] <> map mkTicket tickets
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
          , mkDate ticket.o_date ticket.o_time ticket.origin_place true
          , DOM.div
              { className: "ticket-content sideways_rocket"
              , children: [ DOM.img { src: "assets/sideways_rocket.svg" } ]
              }
          , mkDate ticket.d_date ticket.d_time ticket.destination_place false
          ]
      , onClick: Event.handler_ (setFinalTicket (Just ticket))
      }
    where
    mkDate date time place isSource =
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

mkBookingsPageComponent :: Context.Component BookingsSearch
mkBookingsPageComponent = do
  navbar <- mkNavBarComponent
  Context.component "Bookings" \bookingsSearch -> React.do
    let
      noTickets = DOM.p_ [ DOM.text "No tickets available for this journey" ]
    outboundTickets /\ setOutboundTickets <- React.useState' []
    inboundTickets /\ setInboundTickets <- React.useState' []
    finalOutboundTicket /\ setFinalOutboundTicket <- React.useState' Nothing
    finalInboundTicket /\ setFinalInboundTicket <- React.useState' Nothing
    React.useEffectOnce do
      flip runAff_ (getBookingTickets bookingsSearch) \res -> case res of
        Left err -> throwError err
        Right possTickets -> case possTickets of
          Left err -> throw err
          Right { outboundTickets: oTickets, inboundTickets: iTickets } -> do
            setOutboundTickets oTickets
            setInboundTickets iTickets
      pure mempty
    let
      columnTickets =
        DOM.div
          { className: "column tickets"
          , children:
              [ DOM.div
                  { id: "outbound"
                  , children: mkTickets "Outbound Journeys" outboundTickets setFinalOutboundTicket
                  }
              , if null inboundTickets then
                  noTickets
                else
                  DOM.div
                    { id: "inbound"
                    , children: mkTickets "Inbound Journeys" inboundTickets setFinalInboundTicket
                    }
              ]
          }
    pure
      $ DOM.div
          { className: "bookings-container"
          , children:
              [ navbar { isMainPage: false }
              , mobileSummaryBlock
              , DOM.div
                  { className: "row"
                  , children:
                      if null outboundTickets then
                        [ noTickets ]
                      else
                        [ columnTickets
                        , DOM.span { id: "summaryTop" }
                        , summaryBlock finalOutboundTicket finalInboundTicket
                        ]
                  }
              ]
          }
