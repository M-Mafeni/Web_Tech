module Main where

import Prelude

import Components.HomePage (mkHomePageComponent)
import Components.HomePage.Style (homePageStyleSheet)
import Components.LoginForm.Style (loginFormStyleSheet)
import Components.NavBar.Style (navBarStyleSheet)
import Components.RegisterPage (mkRegisterPageComponent)
import Components.RegisterPage.Style (registerPageStyleSheet)
import Control.Monad.Reader (ask, runReaderT)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
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

mkApp :: Router.Component Unit
mkApp = do
  routerContext <- ask
  registerpage <- mkRegisterPageComponent 
  homepage <- mkHomePageComponent
  Router.component "App" \_ -> R.do
    { route } <- Router.useRouterContext routerContext
    -- route /\ setRoute <- R.useState' (Just HomePage)
    -- R.useEffectOnce do
    --   matches spaceRoutes \_ newRoute -> setRoute newRoute
    pure $ case route of
      Just HomePage -> homepage {isLoggedIn: false, isAdmin: false}
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
      routerProvider <- runReaderT Router.mkRouterProvider routerContext
      app <- runReaderT mkApp routerContext
      ReactDom.render (routerProvider [app unit]) appDiv
      pure unit
