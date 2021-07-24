module Main where

import Prelude

import Components.HomePage (mkHomePageComponent)
import Components.RegisterPage (mkRegisterPageComponent)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM as ReactDom
import React.Basic.Hooks as R
import Router (SpaceRoutes(..), spaceRoutes)
import Routing.Hash (matches)
import Web.DOM.Document (toNonElementParentNode)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

mkApp :: R.Component Unit
mkApp = do
  registerpage <- mkRegisterPageComponent 
  homepage <- mkHomePageComponent
  R.component "App" \_ -> R.do
    route /\ setRoute <- R.useState' (HomePage)
    R.useEffectOnce do
      matches spaceRoutes \_ newRoute -> setRoute newRoute
    pure $ case route of
      HomePage -> homepage {isLoggedIn: false, isAdmin: false}
      RegisterPage -> registerpage unit

main :: Effect Unit
main = do
  doc <- document =<< window
  val <- getElementById "app" $ toNonElementParentNode $ toDocument doc
  case val of
    Nothing -> throw "Could not find element with id = app."
    Just appDiv -> do
      app <- mkApp
      ReactDom.render (app unit) appDiv
      pure unit
