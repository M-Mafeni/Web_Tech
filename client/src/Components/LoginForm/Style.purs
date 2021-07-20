module Components.LoginForm.Style (loginFormStyleSheet) where

import Prelude hiding (top)

import CSS (CSS, Selector, background, backgroundColor, borderRadius, button, byClass, display, displayNone, em, fixed, flex, fontSize, height, justifyContent, left, margin, marginLeft, marginTop, maxWidth, minWidth, nil, padding, pct, position, px, rgba, spaceAround, star, top, width, zIndex, (&), (?), (|*))
import CSS.Common (auto)
import CSS.TextAlign (center, textAlign)
import Style (mainBackgroundColor, makeMediaQueryScreenMaxWidth)

loginTitleSelector :: Selector
loginTitleSelector = star & byClass "login-title"

loginTitleStyle :: CSS
loginTitleStyle = loginTitleSelector ? do
  fontSize (em 3.0)
  textAlign center

loginFormStyle :: CSS
loginFormStyle = star & byClass "login-form" ? do
  display displayNone
  position fixed
  backgroundColor $ rgba 0 0 0 0.4
  width $ pct 100.0
  height $ pct 100.0
  left nil
  top nil
  zIndex 20

loginFormContainerStyle :: CSS
loginFormContainerStyle = star & byClass "login-form-container" ? do
  borderRadius (px 15.0) (px 15.0) (px 15.0) (px 15.0)
  margin auto auto auto auto
  padding (px 5.0) (px 50.0) (px 30.0) (px 50.0)
  width $ pct 50.0
  maxWidth $ px 450.0
  minWidth $ px 250.0
  background mainBackgroundColor 

loginButtonsSelector :: Selector
loginButtonsSelector = star & byClass "login-btns"

loginButtonsStyle :: CSS
loginButtonsStyle = loginButtonsSelector ? do
  marginTop $ px 25.0
  display flex
  justifyContent spaceAround
  width $ pct 50.0
  marginLeft $ pct 20.0

loginMediaQueries :: CSS
loginMediaQueries = makeMediaQueryScreenMaxWidth 550.0 $ do
  loginTitleSelector ? fontSize (em 2.5)
  loginButtonsSelector |* button ? do
    width (pct 100.0)
    marginTop (pct 4.0)

loginFormStyleSheet :: CSS
loginFormStyleSheet = do
  loginTitleStyle
  loginFormStyle
  loginFormContainerStyle
  loginButtonsStyle
  loginMediaQueries