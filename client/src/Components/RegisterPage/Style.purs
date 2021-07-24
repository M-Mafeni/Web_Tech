module Components.RegisterPage.Style (registerPageStyleSheet) where

import Prelude

import CSS (CSS, byClass, fontSize, marginTop, p, pct, star, (&), (?))
import CSS.TextAlign (center, textAlign)
import Style (makeMediaQueryScreenMaxWidth)

registerPageStyleSheet :: CSS
registerPageStyleSheet = do
  let formTitleSelector = star & (byClass "form-title")
  (star & (byClass "login-form-container")) & (byClass "form-container") ? do
    marginTop $ pct 8.0
  formTitleSelector ? do
    textAlign center
    fontSize $ pct 200.0
    marginTop $ pct 2.0
  makeMediaQueryScreenMaxWidth 700.0 $ do
    formTitleSelector ? fontSize (pct 170.0)
  makeMediaQueryScreenMaxWidth 500.0 $
    p & byClass "delete-text" ? fontSize (pct 70.0)
  