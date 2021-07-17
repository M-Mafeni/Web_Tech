module Web.DOMHelper where

import Prelude

import Effect (Effect)
import Web.DOM (Element)

foreign import setInnerHTML :: Element -> String -> Effect Unit
