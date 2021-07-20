module Components.HomePage.Style (homePageStyleSheet) where

import Prelude

import CSS (CSS, backgroundColor, borderRadius, byClass, fontFamily, fontSize, fromInt, margin, marginBottom, pct, px, sansSerif, star, width, (&), (?))
import CSS.Common (auto)
import CSS.TextAlign (center, textAlign)
import Data.NonEmpty (NonEmpty(..))

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

homePageStyleSheet :: CSS
homePageStyleSheet = aboutUsHeaderStyle