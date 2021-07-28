module Components.LoginForm (mkLoginFormComponent) where

import Prelude

import Control.Monad.Reader (ask)
import Data.Monoid (guard)
import Effect (Effect)
import Effect.Class (liftEffect)
import Foreign (unsafeToForeign)
import React.Basic.DOM (css)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (preventDefault)
import React.Basic.Events (handler, handler_)
import React.Basic.Hooks as R
import Router as Router
import Web.HTML (window)
import Web.HTML.Window (innerHeight)

calcLoginPosition :: Effect Int
calcLoginPosition = do
  windowHeight <- innerHeight =<< window
  -- 450 is height of login form
  pure $ (windowHeight - 450) / 2

makeRequiredInput :: String -> String -> String -> String -> R.JSX
makeRequiredInput type1 name placeholder className = DOM.input {
  type: type1,
  name: name,
  placeholder: placeholder,
  className: className,
  required: true
}

--TODO Add code to set the position to be at the centre of the screen
type LoginFormProps = {
  isOpen :: Boolean,
  setIsLoginOpen :: (Boolean -> Boolean) -> Effect Unit
}

mkLoginFormComponent :: Router.Component LoginFormProps
mkLoginFormComponent = do
  loginPos <- liftEffect calcLoginPosition
  routerContext <- ask
  Router.component "LoginForm" $ \props -> R.do
    {nav} <- Router.useRouterContext routerContext
    pure $ guard props.isOpen $ DOM.div {
      className: "login-form",
      id: "loginForm",
      style: css {
        paddingTop: loginPos
        -- paddingTop: (show loginPos) <> "px"
      },
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
                  children: [DOM.text "Create an account."],
                  onClick: handler preventDefault \_ -> do
                    nav.pushState (unsafeToForeign unit) "/register"
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
                  children: [DOM.text "Close"],
                  onClick: handler_ $ props.setIsLoginOpen (const false)
                }
              ]
            }
          ]
        }
      ]
    }