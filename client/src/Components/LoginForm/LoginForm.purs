module Components.LoginForm (mkLoginFormComponent) where

import Prelude

import Affjax as Ax
import Affjax.RequestBody as RequestBody
import Affjax.ResponseFormat as ResponseFormat
import Components.Prompt (PromptResult(..), mkPromptComponent)
import Data.Argonaut (Json, JsonDecodeError, decodeJson, encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.Monoid (guard)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import React.Basic.DOM (css)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (preventDefault, targetValue)
import React.Basic.Events (handler, handler_)
import React.Basic.Hooks as R
import Router as Router
import Web.HTML (window)
import Web.HTML.Location (reload)
import Web.HTML.Window (innerHeight, location)

calcLoginPosition :: Effect Int
calcLoginPosition = do
  windowHeight <- innerHeight =<< window
  -- 450 is height of login form
  pure $ (windowHeight - 450) / 2

makeRequiredInput :: String -> String -> String -> String -> (String -> Effect Unit) -> R.JSX
makeRequiredInput type1 name placeholder className setState = DOM.input {
  type: type1,
  name: name,
  placeholder: placeholder,
  className: className,
  required: true,
  onChange: handler targetValue $ \val -> setState $ fromMaybe "" val
}

--TODO Add code to set the position to be at the centre of the screen
type LoginFormProps = {
  isOpen :: Boolean,
  setIsLoginOpen :: (Boolean -> Boolean) -> Effect Unit
}

type LoginResponse = {
  isLoggedIn :: Maybe Boolean,
  isAdmin :: Maybe Boolean,
  error :: Maybe String
}

loginResponseFromJson :: Json -> Either JsonDecodeError LoginResponse
loginResponseFromJson = decodeJson

mkLoginFormComponent :: Router.Component LoginFormProps
mkLoginFormComponent = do
  loginPos <- liftEffect calcLoginPosition
  prompt <- mkPromptComponent
  Router.component "LoginForm" $ \props -> R.do
    email /\ setEmail <- R.useState' ""
    password /\ setPassword <- R.useState' ""
    promptMessage /\ setPromptMessage <- R.useState' Nothing
    promptResult /\ setPromptResult <- R.useState' Nothing
    pure $ guard props.isOpen $ DOM.div {
      className: "login-form",
      id: "loginForm",
      style: css {
        paddingTop: loginPos
      },
      children: [
        DOM.form {
          className: "login-form-container",
          id: "loginFormContent",
          onSubmit: handler preventDefault $ \_ ->
            launchAff_ do
              responseJson <- Ax.post (ResponseFormat.json) "/login" (Just $ RequestBody.json (encodeJson {email: email, psw: password}))
              case responseJson of
                Left _ -> log $ "An error occured while logging in"
                Right {body} -> do
                  let loginResponse = loginResponseFromJson body
                  liftEffect $ case loginResponse of
                    Left err -> do
                      setPromptMessage $ Just "Failed to Parse Response"
                      setPromptResult $ Just Failure
                      log $ "Failed to Parse Response" <> show err
                    Right res -> do
                      if isJust res.error
                      then do
                        setPromptMessage $ res.error
                        setPromptResult $ Just Failure
                      else do
                        reload =<< location =<< window,
          children: [
            prompt {prompt: promptMessage, result: promptResult},
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
            makeRequiredInput "text" "email" "Enter Email" "" setEmail,
            DOM.label {
              className: "password-label",
              form: "psw",
              children: [DOM.text "Password"]
            },
            makeRequiredInput "password" "psw" "Enter Password" "form_item" setPassword,
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