module Components.LoginForm.Style (loginFormStyleSheet) where

import Prelude hiding (top)

import CSS (CSS, Selector, a, background, backgroundColor, bolder, borderRadius, button, byClass, color, display, displayNone, ease, em, fixed, flex, fontSize, fontWeight, fromInt, height, hover, inlineBlock, justifyContent, left, margin, marginLeft, marginTop, maxWidth, minWidth, nil, p, padding, paddingRight, pct, position, pseudo, px, rgba, sec, spaceAround, star, top, transition, width, zIndex, (&), (?), (|*))
import CSS.Common (auto)
import CSS.TextAlign (center, textAlign)
import Data.Tuple (Tuple(..))
import Style (combineCSS, lightGreenColor, mainBackgroundColor, makeMediaQueryScreenMaxWidth)

loginTitleSelector :: Selector
loginTitleSelector = star & byClass "login-title"

loginTitleStyle :: CSS
loginTitleStyle = loginTitleSelector ? do
  fontSize (em 3.0)
  textAlign center

loginFormStyle :: CSS
loginFormStyle = star & byClass "login-form" ? do
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

registerTextSelector :: Selector
registerTextSelector = (star & byClass "registerText")

registerTextStyle :: CSS
registerTextStyle = registerTextSelector ? do
  textAlign center
  margin (pct 5.0) nil (pct 5.0) nil

registerTextChildrenStyle :: CSS
registerTextChildrenStyle = combineCSS ((star & byClass "registerText") |* _) [Tuple a aCSS, Tuple p pCSS, Tuple aHoverSelector lightGreenStyle, Tuple aFocusSelector lightGreenStyle] where
  aCSS = do
    display inlineBlock
    fontWeight bolder
    color $ fromInt 0xdddddd
    transition "color" (sec 0.3) ease (sec 0.0)
  pCSS = do
    margin nil nil nil nil
    display inlineBlock
    paddingRight $ px 10.0
  aHoverSelector = a & hover
  aFocusSelector = a & pseudo "focus"
  lightGreenStyle = color lightGreenColor

loginFormStyleSheet :: CSS
loginFormStyleSheet = do
  registerTextStyle
  registerTextChildrenStyle
  loginTitleStyle
  loginFormStyle
  loginFormContainerStyle
  loginButtonsStyle
  loginMediaQueries