module Main where

import Prelude

import Components.Footer (mkFooterComponent)
import Components.Navbar (mkNavBarComponent)
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
      navbar <- mkNavBarComponent
      footer <- mkFooterComponent 
      ReactDom.render (navbar {isLoggedIn: false, isAdmin: true, isMainPage: true} <> ReactDom.text "Hello World" <> footer unit) app
