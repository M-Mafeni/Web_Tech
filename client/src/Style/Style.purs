module Style (addStyletoHead) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode) as Element
import Web.DOM.Node (appendChild)
import Web.DOMHelper (setInnerHTML)
import Web.HTML (window)
import Web.HTML.HTMLDocument (head, toDocument)
import Web.HTML.HTMLElement (toNode) as HTMLElement
import Web.HTML.Window (document)


addStyletoHead :: String -> Effect Unit
addStyletoHead styleSheet = do
  htmlDoc <- document =<< window
  possHeadElement <- head htmlDoc
  case possHeadElement of
    Nothing -> throw "Could not find head element"
    Just htmlElement -> do
      let doc = toDocument htmlDoc
      styleTag <- createElement "style" doc
      setInnerHTML styleTag styleSheet
      appendChild (Element.toNode styleTag) (HTMLElement.toNode htmlElement)
      pure unit