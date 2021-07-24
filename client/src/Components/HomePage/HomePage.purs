module Components.HomePage (mkHomePageComponent, HomePageProps) where

import Prelude

import Components.HomePage.Style (homePageStyleSheet)
import Components.NavBar (mkNavBarComponent)
import Components.Prompt (mkPromptComponent)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.Monoid (guard)
import React.Basic.DOM as DOM
import React.Basic.Hooks as R
import Style (addStyletoHead)

type HomePageProps = {
  isLoggedIn :: Boolean,
  isAdmin :: Boolean
}

advertText :: R.JSX
advertText = DOM.div {
  className: "t-minus-text",
  children: [DOM.text "In T-minus 9,8,7,...."]
}

makeDestinationFormItem :: String -> String -> Maybe String -> R.JSX
makeDestinationFormItem name placeholder className = DOM.div {
  className: "form_item",
  children: [
    DOM.input {
      list: "places",
      type: "text",
      name: name,
      placeholder: placeholder,
      className: fromMaybe "" className,
      required: true,
      value: ""
    }
  ]
}

makeDateFormItem :: String -> String -> R.JSX
makeDateFormItem name id = DOM.div {
  className: "form_item",
  children: [
    DOM.input {
      id: id,
      type: "date",
      name: name,
      required: true
    }
  ]
}

bookingBar :: R.JSX
bookingBar = DOM.div {
  className: "booking_bar",
  children: [
    DOM.form {
      className: "booking_form",
      action: "/bookings",
      method: "/GET",
      children: [
        DOM.span {
          className: "booking_left",
          children: [
            makeDestinationFormItem "origin" "Enter Origin Base" Nothing,
            makeDestinationFormItem "destination" "Enter Destination Base" (Just "dest")
            -- TODO Add data list component
          ]
        },
        DOM.span {
          className: "booking_right",
          children: [
            makeDateFormItem "outbound_date" "outbound_date",
            makeDateFormItem "inbound_date" ""
          ]
        },
        DOM.div {
          className: "booking_button",
          children: [
            DOM.input {
              className: "btn",
              type: "submit",
              value: "Find my journey"
            }
          ]
        }
      ]
    }
  ]
}

makeAboutSubSection :: String -> String -> String -> Maybe String ->R.JSX
makeAboutSubSection imgClass imgSrc text maybeSubHeader = DOM.div {
  className: "about_subsection",
  children: [
    DOM.img {
      className: imgClass,
      src: imgSrc
    },
    guard (isJust maybeSubHeader) $ DOM.h2 {
      className: "about_subheader",
      children: [DOM.text $ fromMaybe "" maybeSubHeader]
    },
     DOM.p_ [DOM.text text]
  ]
}
getAboutUsSection :: Boolean -> R.JSX
getAboutUsSection loggedIn = R.fragment [
  DOM.section {
    className: "about_us",
    children: [
      DOM.div {
        className: "header",
        children: [DOM.text "About Us"]
      },
      DOM.div {
        className: "quote_wrapper",
        children: [
          DOM.div {
            className: "quote",
            children:[DOM.em_ [DOM.text "“The future is here, brighter than ever. At Astra, we believe that nobody should be restricted from travelling where their heart desires.”"]]
          },
          DOM.div {
            className: "quote_author",
            children: [DOM.text "- Mr Lorem Ipsum, CEO"]
          }
        ]
      },
      makeAboutSubSection 
        "about_logo"
        "assets/logo_white_embedded.svg"
        "We are an all-in-one online booking service who help coordinate your transportation to get you to your next interplanetary destination. Given your intended date of travel, we list departure and arrival times from 106 different space-travel companies to give you a central website to book your tickets."
        Nothing,
      makeAboutSubSection
        "right_col"
        "assets/spaceX_ship.png"
        "We aim to make your booking process run more smoothly. As space-travel companies expand and increase in number, we understand it can be stressful finding the flight that best suits you. With Astra, you need not worry about these matters as we handle it for you at the click of a button."
        (Just "Our mission"),
      makeAboutSubSection
        "left_col"
        "assets/mars.png"
        "With more than 50 destinations in just the solar system alone, Astra provides a wide range of far off destinations through our partners. You can go from exploring the craters of the Moon to the sands of Mars. Plus, with an Astra-funded satelite at every destination, we can ensure that you will always be connected with Earth."
        (Just "Destinations"),
      DOM.p {
        className: "join_us",
        children: [
          DOM.a {
            href: if loggedIn then "#" else "#register",
            children: [DOM.text $ if loggedIn then "Book your next flight today" else "Join us today"]
          },
          DOM.text " to embark on the journey of your dreams"
        ]
      }
    ]
  }
] 

mkHomePageComponent :: R.Component HomePageProps
mkHomePageComponent = do
  navbar <- mkNavBarComponent
  prompt <- mkPromptComponent
  addStyletoHead homePageStyleSheet
  R.component "HomePage" $ \props -> R.do
    pure $ R.fragment 
      [
        navbar {isAdmin: props.isAdmin, isLoggedIn: props.isLoggedIn, isMainPage: true},
        DOM.div {
          className: "star_bg",
          children: [
            prompt {prompt: Nothing, result: Nothing},
            advertText,
            bookingBar,
            DOM.a {
              name: "about_us",
              id: "about_link",
              children: [DOM.text "about"]
            },
            DOM.img {
              src: "assets/sideways_rocket_animated.svg",
              id: "animated_rocket"
            }
          ]
        },
        getAboutUsSection props.isLoggedIn
      ]
