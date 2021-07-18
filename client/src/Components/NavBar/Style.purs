module Components.NavBar.Style (navBarStyleSheet) where

import Prelude

import CSS (CSS, Float(..), Selector, a, background, block, byClass, clear, clearBoth, color, display, displayNone, ease, easeOut, em, fixed, float, floatLeft, floatRight, fontSize, height, hover, margin, marginLeft, maxHeight, nil, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, pct, position, px, rgba, right, sec, star, transition, white, width, zIndex, (&), (?), (|*))
import CSS.Overflow (hidden, overflow)
import CSS.TextAlign (center, textAlign)
import Data.Tuple (Tuple(..), uncurry)
import Style (combineCSSWithRefinement, concatCSS, mainBackgroundColor, makeMediaQueryScreenMaxWidth)

navItemsSelector :: Selector
navItemsSelector = star & (byClass "nav-items")

navWrapperSelector :: Selector
navWrapperSelector = star & (byClass "nav-wrapper")

navChildItems :: CSS
navChildItems = navItemsSelector ? concatCSS [aStyle, aChildren, icon] where
  aStyle = a ? do
    float floatRight
    paddingLeft (pct 2.0)
    paddingRight (pct 2.0)
    textAlign center
    fontSize (pct 100.0)
    color white
    transition "background" (sec 0.3) ease (sec 0.0)
  aChildren :: CSS
  aChildren = combineCSSWithRefinement (a & _) 
    [
      Tuple hover (background mainBackgroundColor),
      Tuple (byClass "brand-logo") (float floatLeft),
      Tuple (byClass "brand-favicon") (concatCSS [float floatLeft, padding nil nil nil nil, marginLeft (px $ -90.0), display displayNone])
    ]
  icon :: CSS
  icon = star & (byClass "icon") ? do
    display displayNone
    paddingTop (pct 1.0)
    paddingBottom (pct 1.0)

navMobileQueries :: CSS
navMobileQueries =  concatCSS $ map (uncurry makeMediaQueryScreenMaxWidth) [Tuple 750.0 css750, Tuple 550.0 css550] where
  css750 = (navItemsSelector |* (a & byClass "brand-logo")) ? do
    paddingLeft (pct 2.0)
    paddingRight nil
  css550 = do
    let navItemsASelector = navItemsSelector |* a
    combineCSSWithRefinement (navItemsASelector & _ ) [
      Tuple (byClass "icon") $ concatCSS [float floatRight, display block],
      Tuple (byClass "brand-logo") $ display displayNone,
      Tuple (byClass "brand-favicon") $ display block
    ]
    navWrapper
    navWrapperA
    navWrapperResponsive

navItems :: CSS
navItems = navItemsSelector ? do
  width (pct 100.0)
  position fixed
  background $ rgba 0 0 0 0.2
  right $ pct 0.0
  display block
  zIndex 10
  overflow hidden
  transition "background" (sec 0.2) ease (sec 0.0)
  fontSize (pct 80.0)

navLinks :: CSS
navLinks = star & (byClass "nav_links") ? do
  padding (px 15.0) (px 0.0) (px 15.0) (px 0.0)

navLogo :: CSS
navLogo = star & (byClass "nav_logo") ? do
  margin (px 5.0) nil (px 5.0) nil
  height (px 40.0)

navWrapper :: CSS
navWrapper = navWrapperSelector ? do
  clear clearBoth
  transition "background" (sec 0.3) easeOut (sec 0.0)
  margin nil nil nil nil
  padding nil nil nil nil
  overflow hidden
  maxHeight nil

navWrapperA :: CSS
navWrapperA = (navWrapperSelector |* a) ? do
  float FloatNone
  display displayNone
  clear clearBoth

navWrapperResponsive :: CSS
navWrapperResponsive = (navWrapperSelector & byClass "responsive") ? do
  maxHeight $ em 20.0
navBarStyleSheet :: CSS
navBarStyleSheet = do
  navItems
  navLinks
  navChildItems
  navLogo
  navMobileQueries

