module Main where

import Prelude

import Components.HomePage (mkHomePageComponent)
import Components.HomePage.Style (homePageStyleSheet)
import Components.LoginForm.Style (loginFormStyleSheet)
import Components.NavBar.Style (navBarStyleSheet)
import Components.RegisterPage (mkRegisterPageComponent)
import Components.RegisterPage.Style (registerPageStyleSheet)
import Context as Context
import Control.Monad.Reader (ask, runReaderT)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM as ReactDom
import React.Basic.Hooks as R
import Router as Router
import Router.Parser (SpaceRoutes(..))
import Session as Session
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

mkApp :: Context.Component Unit
mkApp = do
  {routerContext} <- ask
  registerpage <- mkRegisterPageComponent 
  homepage <- mkHomePageComponent
  Context.component "App" $ \_ -> R.do
    { route } <- Router.useRouterContext routerContext
    pure $ case route of
      Just HomePage -> homepage unit
      Just RegisterPage -> registerpage unit
      Nothing -> ReactDom.text "404 not Found"

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
      routerContext <- Router.mkRouterContext
      sessionContext <- Session.mkSessionContext
      let context = {routerContext, sessionContext}
      routerProvider <- runReaderT Context.mkRouterProvider context
      sessionProvider <- runReaderT Context.mkSessionProvider context
      app <- runReaderT mkApp {routerContext, sessionContext}
      ReactDom.render (sessionProvider [routerProvider [app unit]]) appDiv
