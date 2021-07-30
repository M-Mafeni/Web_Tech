module Main where

import Prelude

import Affjax as Ax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Components.HomePage (mkHomePageComponent)
import Components.HomePage.Style (homePageStyleSheet)
import Components.LoginForm.Style (loginFormStyleSheet)
import Components.NavBar.Style (navBarStyleSheet)
import Components.RegisterPage (mkRegisterPageComponent)
import Components.RegisterPage.Style (registerPageStyleSheet)
import Control.Monad.Reader (ask, runReaderT)
import Data.Argonaut (decodeJson)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Exception (throw)
import React.Basic.DOM as ReactDom
import React.Basic.Hooks as R
import Router as Router
import Router.Parser (SpaceRoutes(..))
import Style (addStyletoHead)
import Web.DOM.Document (toNonElementParentNode)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

type Session = {
  isLoggedIn :: Maybe Boolean,
  isAdmin :: Maybe Boolean
}

mkApp :: Router.Component Session
mkApp = do
  routerContext <- ask
  registerpage <- mkRegisterPageComponent 
  homepage <- mkHomePageComponent
  Router.component "App" \session -> R.do
    { route } <- Router.useRouterContext routerContext
    -- route /\ setRoute <- R.useState' (Just HomePage)
    -- R.useEffectOnce do
    --   matches spaceRoutes \_ newRoute -> setRoute newRoute
    pure $ case route of
      Just HomePage -> homepage {isLoggedIn: fromMaybe false session.isLoggedIn, isAdmin: fromMaybe false session.isAdmin}
      Just RegisterPage -> registerpage unit
      Nothing -> ReactDom.text "404 not Found"


getSession :: Aff (Either String Session)
getSession = do
  responseJson <- Ax.get ResponseFormat.json "/session"
  case responseJson of
    Left err -> do
      pure $ Left $ "an Error occured while getting the session " <> Ax.printError err
    Right {body, status, statusText} -> do
      if status == (StatusCode 200)
      then do
        let sessionJson = decodeJson body
        case sessionJson of
          Left err -> do
             pure $ Left $ "Failed to Parse Response" <> show err
          Right val -> pure $ Right val
      else do
        pure $ Left $ statusText

main :: Effect Unit
main = do
  doc <- document =<< window
  val <- getElementById "app" $ toNonElementParentNode $ toDocument doc
  case val of
    Nothing -> throw "Could not find element with id = app."
    Just appDiv -> do
      traverse_ addStyletoHead [
        homePageStyleSheet,
        loginFormStyleSheet,
        navBarStyleSheet,
        registerPageStyleSheet]
      flip runAff_ getSession $ \possValue -> do
        case possValue of
          Left err -> throw $ show err
          Right eitherErrSession -> case eitherErrSession of
            Left err -> throw $ show err
            Right session -> do
              routerContext <- Router.mkRouterContext
              routerProvider <- runReaderT Router.mkRouterProvider routerContext
              app <- runReaderT mkApp routerContext
              ReactDom.render (routerProvider [app session]) appDiv
              pure unit
