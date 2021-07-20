module Components.LoginForm (mkLoginFormComponent) where

import Prelude

import Components.LoginForm.Style (loginFormStyleSheet)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, JSX, component) as R
import Style (addStyletoHead)

makeRequiredInput :: String -> String -> String -> String -> R.JSX
makeRequiredInput type1 name placeholder className = DOM.input {
  type: type1,
  name: name,
  placeholder: placeholder,
  className: className,
  required: true
}

mkLoginFormComponent :: R.Component Unit
mkLoginFormComponent = do
  addStyletoHead loginFormStyleSheet
  R.component "LoginForm" $ \_ -> pure $ DOM.div {
    className: "login-form",
    id: "loginForm",
    children: [
      DOM.form {
        className: "login-form-container",
        id: "loginFormContent",
        action: "/login",
        method: "post",
        children: [
          DOM.h1 {
            className: "login-title",
            children: [DOM.text "Login"]
          },
          DOM.div {
            className: "registerText",
            children: [
              DOM.p_ [DOM.text "New to Astra?"],
              DOM.a {
                href: "/register",
                children: [DOM.text "Create an account."]
              }
            ]
          },
          DOM.label {
            className: "email-label",
            form: "email",
            children: [DOM.text "Email"]
          },
          makeRequiredInput "text" "email" "Enter Email" "",
          DOM.label {
            className: "password-label",
            form: "psw",
            children: [DOM.text "Password"]
          },
          makeRequiredInput "password" "psw" "Enter Password" "form_item",
          DOM.div {
            className: "login-btns",
            children: [
              DOM.button {
                type: "submit",
                className: "btn",
                children: [DOM.text "Login"]
              },
              DOM.button {
                id: "login_close",
                type: "reset",
                className: "btn cancel",
                children: [DOM.text "Close"]
              }
            ]
          }
        ]
      }
    ]
  }