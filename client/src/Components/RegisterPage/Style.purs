module Components.RegisterPage.Style (registerPageStyleSheet) where

import Prelude

import CSS (CSS, body, byClass, fontSize, margin, marginTop, minWidth, nil, p, paddingTop, pct, px, star, width, (&), (?))
import CSS.TextAlign (center, textAlign)
import Style (makeMediaQueryScreenMaxWidth)

registerPageStyleSheet :: CSS
registerPageStyleSheet = do
  let formTitleSelector = star & (byClass "form-title")
  body ? do
    margin (px 100.0) nil (px 100.0) nil
  star & (byClass "form-container") ? do
    paddingTop $ px 40.0
    minWidth $ px 270.0
    width $ pct 70.0
  formTitleSelector ? do
    textAlign center
    fontSize $ pct 200.0
    marginTop $ pct 2.0
  makeMediaQueryScreenMaxWidth 700.0 $ do
    formTitleSelector ? fontSize (pct 170.0)
  makeMediaQueryScreenMaxWidth 500.0 $
    p & byClass "delete-text" ? fontSize (pct 70.0)
  