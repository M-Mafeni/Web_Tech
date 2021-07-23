module Style (
  addStyletoHead,
  renderStyleSheet,
  mainBackgroundColor,
  combineCSSWithSelector,
  combineCSSWithRefinement,
  concatCSS,
  makeMediaQueryScreenMaxWidth,
  combineCSS,
  lightGreenColor
  ) where

import Prelude

import CSS (CSS, Color, Inline, Refinement, Selector, Sheet, fromInt, getInline, getSheet, px, query, render, (?))
import CSS.Media (maxWidth, screen) as Media
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..))
import Data.NonEmpty (NonEmpty(..))
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
lightGreenColor :: Color
lightGreenColor = fromInt 0x2cbbad

getStyleSheet :: These Inline Sheet -> String
getStyleSheet = these getInline getSheet (\x y -> getInline x <> getSheet y)

renderStyleSheet :: CSS -> String
renderStyleSheet stylesheet = case render stylesheet of
  Nothing -> mempty
  Just value -> getStyleSheet value

combineCSSWithSelector :: (Selector -> Selector) -> Array (Tuple Selector CSS) -> CSS
combineCSSWithSelector = combineCSS
combineCSSWithRefinement :: (Refinement -> Selector) -> Array (Tuple Refinement CSS) -> CSS
combineCSSWithRefinement = combineCSS

combineCSS :: forall a. (a -> Selector) -> Array (Tuple a CSS) -> CSS
combineCSS selFn = (void <<< sequence <<< map (uncurry (?) <<< lmap selFn))

concatCSS :: Array CSS -> CSS
concatCSS = void <<< sequence

makeMediaQueryScreenMaxWidth :: Number -> CSS -> CSS
makeMediaQueryScreenMaxWidth val = query Media.screen (NonEmpty (Media.maxWidth $ px val) []) 

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