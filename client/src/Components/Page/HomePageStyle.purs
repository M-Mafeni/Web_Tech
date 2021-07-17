module Components.Page.HomePageStyle (homePageStyleSheet) where

import Prelude

import CSS (CSS, Inline, Sheet, backgroundColor, borderRadius, byClass, fontFamily, fontSize, fromInt, getInline, getSheet, margin, marginBottom, pct, px, render, sansSerif, star, width, (&), (?))
import CSS.Common (auto)
import CSS.TextAlign (center, textAlign)
import Data.Maybe (Maybe(..))
import Data.NonEmpty (NonEmpty(..))
import Data.These (These, these)
import React.Basic (JSX)
import React.Basic.DOM as DOM

aboutUsHeaderStyle :: CSS
aboutUsHeaderStyle = star & (byClass "header") ? do
  backgroundColor $ fromInt 0x007cbf
  fontFamily ["Righteous"] $ NonEmpty sansSerif []
  fontSize (px 60.0)
  textAlign center
  width (pct 50.0)
  margin (px 0.0) auto (px 0.0) auto
  marginBottom (pct 8.0)
  borderRadius (px 15.0) (px 15.0) (px 15.0) (px 15.0)

homePageStyle :: CSS
homePageStyle = aboutUsHeaderStyle

getStyleSheet :: These Inline Sheet -> String
getStyleSheet = these getInline getSheet (\x y -> getInline x <> getSheet y)

homePageStyleSheet :: JSX
homePageStyleSheet = case render homePageStyle of
  Nothing -> mempty
  Just value -> DOM.style_ [DOM.text $ getStyleSheet value]