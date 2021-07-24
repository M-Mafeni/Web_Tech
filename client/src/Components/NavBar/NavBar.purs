module Components.NavBar (mkNavBarComponent, NavBarProps) where

import Prelude

import Components.LoginForm (mkLoginFormComponent)
import Components.NavBar.Style (navBarStyleSheet)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Monoid (guard)
import Data.Tuple.Nested ((/\))
import React.Basic.DOM as DOM
import React.Basic.Events (handler_)
import React.Basic.Hooks as R
import Style (addStyletoHead)

type NavBarProps = {
  isLoggedIn :: Boolean,
  isAdmin :: Boolean,
  isMainPage :: Boolean
}

makeSimpleNavlink :: String -> String -> Maybe String -> R.JSX
makeSimpleNavlink href text id = DOM.a {
  className: "nav_links",
  href: href,
  children: [DOM.text text],
  id: fromMaybe "" id
}
 
mkNavBarComponent :: R.Component NavBarProps
mkNavBarComponent = do
  loginForm <- mkLoginFormComponent
  addStyletoHead navBarStyleSheet
  R.component "NavBar" $ \props -> R.do
    (isLoginOpen /\ setIsLoginOpen) <- R.useState false
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
    let loginLinks = if props.isLoggedIn 
      then [
        makeSimpleNavlink "/logout" "Logout" Nothing,
        makeSimpleNavlink "/account" "My Account" Nothing
      ]
      else [
        loginLink
      ]
    let admin = guard (props.isLoggedIn && props.isAdmin) $ makeSimpleNavlink "/admin" "Admin" Nothing
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
