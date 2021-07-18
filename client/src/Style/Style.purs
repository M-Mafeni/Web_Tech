module Style (
  addStyletoHead,
  renderStyleSheet,
  mainBackgroundColor,
  combineCSSWithSelector,
  combineCSSWithRefinement,
  concatCSS
  ) where

import Prelude

import CSS (CSS, Color, Inline, Refinement, Selector, Sheet, fromInt, getInline, getSheet, render, (?))
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..))
import Data.These (These, these)
import Data.Traversable (sequence)
import Data.Tuple (Tuple, uncurry)
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

mainBackgroundColor :: Color
mainBackgroundColor = fromInt 0x007cbf

getStyleSheet :: These Inline Sheet -> String
getStyleSheet = these getInline getSheet (\x y -> getInline x <> getSheet y)

renderStyleSheet :: CSS -> String
renderStyleSheet stylesheet = case render stylesheet of
  Nothing -> mempty
  Just value -> getStyleSheet value

combineCSSWithSelector :: (Selector -> Selector) -> Array (Tuple Selector CSS) -> CSS
combineCSSWithSelector selFn = (void <<< sequence <<< map (uncurry (?) <<< lmap selFn))

combineCSSWithRefinement :: (Refinement -> Selector) -> Array (Tuple Refinement CSS) -> CSS
combineCSSWithRefinement selFn = (void <<< sequence <<< map (uncurry (?) <<< lmap selFn))

concatCSS :: Array CSS -> CSS
concatCSS = void <<< sequence

addStyletoHead :: CSS -> Effect Unit
addStyletoHead style = do
  let styleSheet = renderStyleSheet style
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