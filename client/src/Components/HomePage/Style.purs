module Components.HomePage.Style (homePageStyleSheet) where

import Prelude

import CSS (CSS, background, backgroundColor, backgroundImage, backgroundSize, borderRadius, byClass, cover, fontFamily, fontSize, fromInt, height, margin, marginBottom, nil, padding, paddingTop, pct, px, sansSerif, star, url, width, (&), (?))
import CSS.Common (auto)
import CSS.TextAlign (center, textAlign)
import Data.NonEmpty (NonEmpty(..))
import Style (mainBackgroundColor)

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

starBackgroundStyle :: CSS
starBackgroundStyle = star & (byClass "star_bg") ? do
  backgroundImage $ url "/assets/space.png"
  backgroundSize cover
  width $ pct 100.0
  height $ px 630.0
  paddingTop $ pct 10.0
  textAlign center
  margin nil auto (pct 2.0) auto

tMinusTextStyle :: CSS
tMinusTextStyle = star & (byClass "t-minus-text") ? do
  textAlign center
  fontSize $ pct 330.0

bookingBarStyle :: CSS
bookingBarStyle = star & (byClass "booking_bar") ? do
  margin (pct 5.0) auto (pct 5.0) auto
  width $ pct 75.0
  padding (pct 1.0) (pct 2.0) (pct 1.0) (pct 1.0)
  borderRadius (px 15.0) (px 15.0) (px 15.0) (px 15.0)
  background mainBackgroundColor

homePageStyleSheet :: CSS
homePageStyleSheet = do
  starBackgroundStyle
  aboutUsHeaderStyle
  tMinusTextStyle
  bookingBarStyle
