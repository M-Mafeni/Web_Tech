module Components.HomePage.BookingBar (mkBookingBarComponent) where

import Prelude
import Context as Context
import Control.Monad.Reader (ask)
import Data.BookingsSearch (makeBookingQueryString)
import Data.Destination (Destination)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Foreign (unsafeToForeign)
import React.Basic (JSX)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (preventDefault, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks as React
import Router as Router
import Session as Session

makeDestinationFormItem :: String -> String -> Maybe String -> (String -> Effect Unit) -> JSX
makeDestinationFormItem name placeholder className setValue =
  DOM.div
    { className: "form_item"
    , children:
        [ DOM.input
            { list: "places"
            , type: "text"
            , name: name
            , placeholder: placeholder
            , className: fromMaybe "" className
            , required: true
            , onChange: handler (preventDefault >>> targetValue) (fromMaybe "" >>> setValue)
            }
        ]
    }

makeDateFormItem :: String -> String -> (String -> Effect Unit) -> JSX
makeDateFormItem name id setValue =
  DOM.div
    { className: "form_item"
    , children:
        [ DOM.input
            { id: id
            , type: "date"
            , name: name
            , required: true
            , onChange: handler (preventDefault >>> targetValue) (fromMaybe "" >>> setValue)
            }
        ]
    }

type BookingBarProps
  = { destinations :: Array Destination
    , setErrMessage :: Maybe String -> Effect Unit
    }

mkBookingBarComponent :: Context.Component BookingBarProps
mkBookingBarComponent = do
  { sessionContext, routerContext } <- ask
  Context.component "BookingBar" \{ destinations, setErrMessage } -> React.do
    session <- Session.useSessionContext sessionContext
    { nav } <- Router.useRouterContext routerContext
    origin /\ setOrigin <- React.useState' ""
    destination /\ setDestination <- React.useState' ""
    outboundDate /\ setOutboundDate <- React.useState' ""
    inboundDate /\ setInboundDate <- React.useState' ""
    pure
      $ DOM.div
          { className: "booking_bar"
          , children:
              [ DOM.form
                  { className: "booking_form"
                  , action: "/bookings"
                  , method: "/GET"
                  , children:
                      [ DOM.span
                          { className: "booking_left"
                          , children:
                              [ makeDestinationFormItem "origin" "Enter Origin Base" Nothing setOrigin
                              , makeDestinationFormItem "destination" "Enter Destination Base" (Just "dest") setDestination
                              , DOM.datalist
                                  { id: "places"
                                  , children: map (\dest -> DOM.option { value: dest.name }) destinations
                                  }
                              ]
                          }
                      , DOM.span
                          { className: "booking_right"
                          , children:
                              [ makeDateFormItem "outbound_date" "outbound_date" setOutboundDate
                              , makeDateFormItem "inbound_date" "" setInboundDate
                              ]
                          }
                      , DOM.div
                          { className: "booking_button"
                          , children:
                              [ DOM.input
                                  { className: "btn"
                                  , type: "submit"
                                  , value: "Find my journey"
                                  , onClick:
                                      handler preventDefault \_ -> do
                                        if session.isLoggedIn then do
                                          nav.pushState (unsafeToForeign {}) ("/bookings" <> makeBookingQueryString { origin, destination, outbound_date: outboundDate, inbound_date: inboundDate })
                                        else
                                          setErrMessage (Just "You are not logged in")
                                  }
                              ]
                          }
                      ]
                  }
              ]
          }
