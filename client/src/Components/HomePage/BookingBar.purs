module Components.HomePage.BookingBar (mkBookingBarComponent) where

import Prelude
import Context as Context
import Control.Monad.Reader (ask)
import Data.Destination (Destination)
import Data.Maybe (Maybe(..), fromMaybe)
import Prim.TypeError (class Warn, Text)
import React.Basic (JSX)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (preventDefault)
import React.Basic.Events (handler)
import React.Basic.Hooks as React
import Session as Session

makeDestinationFormItem :: String -> String -> Maybe String -> JSX
makeDestinationFormItem name placeholder className =
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
            }
        ]
    }

makeDateFormItem :: String -> String -> JSX
makeDateFormItem name id =
  DOM.div
    { className: "form_item"
    , children:
        [ DOM.input
            { id: id
            , type: "date"
            , name: name
            , required: true
            }
        ]
    }

mkBookingBarComponent :: Warn (Text "Implement onSubmit handler in Booking Bar") => Context.Component (Array Destination)
mkBookingBarComponent = do
  { sessionContext } <- ask
  Context.component "BookingBar" \destinations -> React.do
    session <- Session.useSessionContext sessionContext
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
                              [ makeDestinationFormItem "origin" "Enter Origin Base" Nothing
                              , makeDestinationFormItem "destination" "Enter Destination Base" (Just "dest")
                              , DOM.datalist
                                  { id: "places"
                                  , children: map (\destination -> DOM.option { value: destination.name }) destinations
                                  }
                              ]
                          }
                      , DOM.span
                          { className: "booking_right"
                          , children:
                              [ makeDateFormItem "outbound_date" "outbound_date"
                              , makeDateFormItem "inbound_date" ""
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
                                          pure unit
                                        else
                                          pure unit
                                  }
                              ]
                          }
                      ]
                  }
              ]
          }
