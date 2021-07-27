module Router.Parser (spaceRoutes, SpaceRoutes(..)) where

import Prelude

import Data.Foldable (oneOf)
import Routing.Match (Match, end, lit)

data SpaceRoutes = HomePage | RegisterPage

instance showSpaceRoutes :: Show SpaceRoutes where
  show (HomePage) = "/"
  show (RegisterPage) = "/register"

spaceRoutes :: Match SpaceRoutes
spaceRoutes = oneOf [
  (RegisterPage <$ lit "register"),
  pure HomePage
] <* end
