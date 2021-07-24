module Components.RegisterPage (RegisterPageProps, mkRegisterPageComponent)  where

import Prelude

import Components.NavBar (mkNavBarComponent)
import Components.Prompt (mkPromptComponent)
import Components.RegisterPage.Style (registerPageStyleSheet)
import Data.Maybe (Maybe(..))
import React.Basic.DOM as DOM
import React.Basic.Hooks as R
import Style (addStyletoHead)
import Web.HTML.HTMLInputElement (placeholder)

-- import Web.DOM.Element (className)

type RegisterPageProps = Unit

type PlaceHolder = String
type InputType = String
makeInputBox :: String -> String-> InputType -> PlaceHolder -> R.JSX
makeInputBox name text inputType placeholder = R.fragment [
  DOM.label {
    htmlFor: name,
    children: [DOM.text text]
  },
  DOM.input {
    type: inputType,
    name: name,
    placeholder: placeholder,
    required: true
  }
]
mkRegisterPageComponent :: R.Component RegisterPageProps
mkRegisterPageComponent = do
  addStyletoHead registerPageStyleSheet
  navbar <- mkNavBarComponent
  prompt <- mkPromptComponent
  R.component "RegisterPage" $ \props -> do
    let registerForm = DOM.form {
        className: "login-form-container form-container",
        action: "/registered",
        method: "post",
        children: [
          DOM.h1 {className: "form-title", children: [DOM.text "Register"]},
          makeInputBox "first_name" "First Name" "text" "Enter First Name",
          makeInputBox "last_name" "Last Name" "text" "Enter Last Name",
          makeInputBox "email" "Email" "text" "Enter Email",
          makeInputBox "address" "Address" "text" "Enter Address",
          makeInputBox "psw" "Password" "password" "Enter Password",
          makeInputBox "confirm_psw" "Password" "password" "Confirm Password"
        ]
    }
    let registerBtn = DOM.div {
      className: "login-btns",
      children: [DOM.button {type: "submit", className: "btn", children: [DOM.text "Register"]}]
    }
    pure $ R.fragment 
      [ 
        navbar {isAdmin: false, isLoggedIn: false, isMainPage: false},
        prompt {prompt: Nothing, result: Nothing},
        registerForm,
        registerBtn
      ]

