module Components.NavBar (mkNavBarComponent, NavBarProps) where

import Prelude

import Components.LoginForm (mkLoginFormComponent)
import Context as Context
import Control.Monad.Reader (ask)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Monoid (guard)
import Data.Tuple.Nested ((/\))
import React.Basic.DOM as DOM
import React.Basic.Events (handler_)
import React.Basic.Hooks as R
import Session as Session

type NavBarProps = {
  isMainPage :: Boolean
}

makeSimpleNavlink :: String -> String -> Maybe String -> R.JSX
makeSimpleNavlink href text id = DOM.a {
  className: "nav_links",
  href: href,
  children: [DOM.text text],
  id: fromMaybe "" id
}
 
mkNavBarComponent :: Context.Component NavBarProps
mkNavBarComponent = do
  loginForm <- mkLoginFormComponent
  {sessionContext} <- ask
  Context.component "NavBar" $ \props -> R.do
    (isLoginOpen /\ setIsLoginOpen) <- R.useState false
    session <- Session.useSessionContext sessionContext
    let styleSheet = guard (not props.isMainPage) DOM.link {
      rel: "stylesheet",
      href: "styles/navbar.css"
    }
    let navLogos = [
      DOM.a {
        href: if props.isMainPage then "#" else "/",
        className: "brand-logo",
        children: [
          DOM.img {
            className: "nav_logo",
            src: "assets/logo_white_embedded.svg"
          }
        ]
      },
      DOM.a {
        href: if props.isMainPage then "#" else "/",
        className: "brand-favicon",
        children: [
          DOM.img {
            className: "nav_favicon",
            src: "assets/favicon_white.png"
          }
        ]
      }
    ]
    let icon = DOM.a {
      className: "icon",
      children: [DOM.i {className: "fa fa-bars"}]
    }
    let loginLink = DOM.a {
        className: "nav_links",
        href: "#",
        children: [DOM.text "Login/Register"],
        id: "login_link",
        onClick: handler_ (setIsLoginOpen (\_ -> true))
      }
    let loginLinks = if session.isLoggedIn 
      then [
        makeSimpleNavlink "/logout" "Logout" Nothing,
        makeSimpleNavlink "/account" "My Account" Nothing
      ]
      else [
        loginLink
      ]
    let admin = guard (session.isLoggedIn && session.isAdmin) $ makeSimpleNavlink "/admin" "Admin" Nothing
    let aboutUs = guard props.isMainPage $ makeSimpleNavlink "#about_us" "About Us" (Just "about_nav_link")
    let navWrapper = DOM.div {
      className: "nav-wrapper",
      id: "mobile-nav",
      children: (loginLinks <> [admin, aboutUs])
    }
    let mobileNavBackground = DOM.div {id: "mobile-nav-bg"}
    let navItems = DOM.div {
      className: "nav-items",
      id: "topnav",
      children: [styleSheet] <> navLogos <> [icon, navWrapper]
    }
    pure $ R.fragment [
      loginForm {isOpen: isLoginOpen, setIsLoginOpen: setIsLoginOpen}
      , navItems
      , mobileNavBackground]
