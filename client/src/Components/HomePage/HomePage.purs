module Components.HomePage (mkHomePageComponent, HomePageProps) where

import Prelude

import Components.HomePage.BookingBar (mkBookingBarComponent)
import Components.NavBar (mkNavBarComponent)
import Components.Prompt (PromptResult(..), mkPromptComponent)
import Context as Context
import Control.Monad.Reader (ask)
import Data.Destination (getDestinations)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.Monoid (guard)
import Data.Tuple.Nested ((/\))
import Effect.Aff (killFiber, launchAff_, runAff)
import Effect.Exception (error, throw) as Exception
import Foreign (unsafeToForeign)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (preventDefault)
import React.Basic.Events (handler)
import React.Basic.Hooks as R
import Router as Router
import Routing.PushState (PushStateInterface)
import Session as Session

type HomePageProps
  = Unit

advertText :: R.JSX
advertText =
  DOM.div
    { className: "t-minus-text"
    , children: [ DOM.text "In T-minus 9,8,7,...." ]
    }

makeAboutSubSection :: String -> String -> String -> Maybe String -> R.JSX
makeAboutSubSection imgClass imgSrc text maybeSubHeader =
  DOM.div
    { className: "about_subsection"
    , children:
        [ DOM.img
            { className: imgClass
            , src: imgSrc
            }
        , guard (isJust maybeSubHeader)
            $ DOM.h2
                { className: "about_subheader"
                , children: [ DOM.text $ fromMaybe "" maybeSubHeader ]
                }
        , DOM.p_ [ DOM.text text ]
        ]
    }

getAboutUsSection :: Boolean -> PushStateInterface -> R.JSX
getAboutUsSection loggedIn nav =
  R.fragment
    [ DOM.section
        { className: "about_us"
        , children:
            [ DOM.div
                { className: "header"
                , children: [ DOM.text "About Us" ]
                }
            , DOM.div
                { className: "quote_wrapper"
                , children:
                    [ DOM.div
                        { className: "quote"
                        , children: [ DOM.em_ [ DOM.text "“The future is here, brighter than ever. At Astra, we believe that nobody should be restricted from travelling where their heart desires.”" ] ]
                        }
                    , DOM.div
                        { className: "quote_author"
                        , children: [ DOM.text "- Mr Lorem Ipsum, CEO" ]
                        }
                    ]
                }
            , makeAboutSubSection
                "about_logo"
                "assets/logo_white_embedded.svg"
                "We are an all-in-one online booking service who help coordinate your transportation to get you to your next interplanetary destination. Given your intended date of travel, we list departure and arrival times from 106 different space-travel companies to give you a central website to book your tickets."
                Nothing
            , makeAboutSubSection
                "right_col"
                "assets/spaceX_ship.png"
                "We aim to make your booking process run more smoothly. As space-travel companies expand and increase in number, we understand it can be stressful finding the flight that best suits you. With Astra, you need not worry about these matters as we handle it for you at the click of a button."
                (Just "Our mission")
            , makeAboutSubSection
                "left_col"
                "assets/mars.png"
                "With more than 50 destinations in just the solar system alone, Astra provides a wide range of far off destinations through our partners. You can go from exploring the craters of the Moon to the sands of Mars. Plus, with an Astra-funded satelite at every destination, we can ensure that you will always be connected with Earth."
                (Just "Destinations")
            , DOM.p
                { className: "join_us"
                , children:
                    [ DOM.a
                        { href: if loggedIn then "#" else "/register"
                        , children: [ DOM.text $ if loggedIn then "Book your next flight today" else "Join us today" ]
                        , onClick:
                            handler preventDefault \_ -> do
                              if loggedIn then
                                pure unit
                              else
                                nav.pushState (unsafeToForeign unit) "/register"
                        }
                    , DOM.text " to embark on the journey of your dreams"
                    ]
                }
            ]
        }
    ]

mkHomePageComponent :: Context.Component HomePageProps
mkHomePageComponent = do
  navbar <- mkNavBarComponent
  prompt <- mkPromptComponent
  bookingBar <- mkBookingBarComponent
  { routerContext, sessionContext } <- ask
  Context.component "HomePage"
    $ \_ -> R.do
        { nav } <- Router.useRouterContext routerContext
        session <- Session.useSessionContext sessionContext
        destinations /\ setDestinations <- R.useState' []
        errMessage /\ setErrMessage <- R.useState' Nothing
        R.useEffectOnce do
          fiber <- flip runAff getDestinations
            $ \destinationsValue -> case destinationsValue of
                Left err -> Exception.throw $ show err
                Right possDestinationJson -> case possDestinationJson of
                  Left err -> Exception.throw err
                  Right destinationsJson -> setDestinations destinationsJson
          pure $ launchAff_ $ killFiber (Exception.error "Canceled") fiber
        pure
          $ R.fragment
              [ navbar { isMainPage: true }
              , DOM.div
                  { className: "star_bg"
                  , children:
                      [ prompt { prompt: errMessage, result: Just Failure }
                      , advertText
                      , bookingBar {destinations, setErrMessage}
                      , DOM.a
                          { name: "about_us"
                          , id: "about_link"
                          , children: [ DOM.text "about" ]
                          }
                      , DOM.img
                          { src: "assets/sideways_rocket_animated.svg"
                          , id: "animated_rocket"
                          }
                      ]
                  }
              , getAboutUsSection session.isLoggedIn nav
              ]
