module Main where

import Prelude

import Components.HomePage (mkHomePageComponent)
import Components.RegisterPage (mkRegisterPageComponent)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM as ReactDom
import Web.DOM.Document (toNonElementParentNode)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)


main :: Effect Unit
main = do
  doc <- document =<< window
  val <- getElementById "app" $ toNonElementParentNode $ toDocument doc
  case val of
    Nothing -> throw "Could not find element with id = app."
    Just app -> do
      -- homepage <- mkHomePageComponent
      registerpage <- mkRegisterPageComponent
      -- ReactDom.render (homepage {isLoggedIn: false, isAdmin: false}) app
      ReactDom.render (registerpage unit) app

