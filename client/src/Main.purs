module Main where

import Prelude

import Components.BookingsPage (mkBookingsPageComponent)
import Components.ConfirmationPage (mkConfirmationPageComponent)
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
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM as ReactDom
import React.Basic.Hooks as R
import Router as Router
import Router.Parser (SpaceRoutes(..))
import Session as Session
import Simple.JSON (read_)
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
  bookingsPage <- mkBookingsPageComponent
  confirmationPage <- mkConfirmationPageComponent
  Context.component "App" $ \_ -> R.do
    { route, nav } <- Router.useRouterContext routerContext
    confirmationPageProps /\ setConfirmationPageProps <- R.useState' Nothing
    R.useEffect route do
      {state} <- nav.locationState
      setConfirmationPageProps (if (route == Just ConfirmationPage) then (read_ state) else Nothing)
      pure mempty
    pure $ case route of
      Just HomePage -> homepage unit
      Just RegisterPage -> registerpage unit
      Just (BookingsPage maybeSearch) -> case maybeSearch of
        --If search query doesn't exist reidrect to the home page
        Nothing -> homepage unit
        Just search -> bookingsPage search
      Just ConfirmationPage -> case confirmationPageProps of 
        Nothing -> ReactDom.text "Could not Parse Confirmation Page Data"
        Just props -> confirmationPage props
      _ -> ReactDom.text "404 not Found"

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
