module Components.BookingsPage (mkBookingsPageComponent) where

import Prelude

import Components.NavBar (mkNavBarComponent)
import Components.Spinner (mkSpinner)
import Context as Context
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
import React.Basic.Events as Event
import React.Basic.Hooks (JSX)
import React.Basic.Hooks as React
import Web.DOM.Document (toNonElementParentNode)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.HTMLFormElement as Form
import Web.HTML.Window (document)

mobileSummaryBlock :: (Maybe Ticket) -> (Maybe Ticket) -> Boolean -> ((Boolean -> Boolean) -> Effect Unit) -> JSX
mobileSummaryBlock finalOutboundTicket finalInboundTicket showMobileDetail setShowMobileDetail =
  DOM.div
    { className: "summary-icon"
    , children:
        [ DOM.span
            { id: "summary-title-mobile"
            , children: [ DOM.text $ if (isNothing finalOutboundTicket && isNothing finalInboundTicket) then "No ticket selected" else "Summary" ]
            }
        , DOM.i
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
            { type: "submit"
            , className: "btn continue-mobile"
            , children: [ DOM.text "Continue" ]
            , onClick:
                Event.handler_ do
                  doc <- document =<< window
                  val <- (join <<< map Form.fromElement) <$> (getElementById "hidden-form" $ toNonElementParentNode $ toDocument doc)
                  case val of
                    Nothing -> throw "Unable to locate hidden form"
                    Just hiddenFormElem -> Form.submit hiddenFormElem
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

hiddenForm :: Boolean -> JSX
hiddenForm canSubmit =
  DOM.form
    { id: "hidden-form"
    , action: "/confirmation"
    , method: "POST"
    , children:
        [ DOM.div
            { className: "hidden-form"
            , children: f true <> f false
            }
        , guard canSubmit DOM.button
            { type: "submit"
            , name: "continue"
            , className: "btn"
            , children: [ DOM.text "Continue" ]
            }
        ]
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
        , hiddenForm (isJust finalOutboundTicket && isJust finalInboundTicket)
        ]
    }
  where
  finalPriceText = case (finalOutboundTicket /\ finalInboundTicket) of
    (Nothing /\ Nothing) -> ""
    (Just t1 /\ Just t2) -> "£" <> (show $ t1.price + t2.price)
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
  spinner <- liftEffect mkSpinner
  Context.component "Bookings" \bookingsSearch -> React.do
    let
      noTickets = DOM.p_ [ DOM.text "No tickets available for this journey" ]
    outboundTickets /\ setOutboundTickets <- React.useState' []
    inboundTickets /\ setInboundTickets <- React.useState' []
    finalOutboundTicket /\ setFinalOutboundTicket <- React.useState' Nothing
    finalInboundTicket /\ setFinalInboundTicket <- React.useState' Nothing
    showMobileDetail /\ setShowMobileDetail <- React.useState false
    isLoading /\ setIsLoading <- React.useState' true
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
              , if isLoading then
                  spinner
                else
                  React.fragment
                    [ mobileSummaryBlock finalOutboundTicket finalInboundTicket showMobileDetail setShowMobileDetail
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
              ]
          }
