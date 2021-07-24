module Router (spaceRoutes, SpaceRoutes(..)) where

import Prelude

import Data.Foldable (oneOf)
import Routing.Match (Match, end, lit, root)

data SpaceRoutes = HomePage | RegisterPage

instance showSpaceRoutes :: Show SpaceRoutes where
  show (HomePage) = "HomePage"
  show (RegisterPage) = "RegisterPage"

spaceRoutes :: Match SpaceRoutes
spaceRoutes = oneOf [
  (RegisterPage <$ lit "register"),
  HomePage <$ root
] <* end
