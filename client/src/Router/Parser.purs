module Router.Parser (spaceRoutes, SpaceRoutes(..)) where

import Prelude

import Control.Alt ((<|>))
import Data.Foldable (oneOf)
import Data.Maybe (Maybe(..))
import Routing.Match (Match, end, lit, optionalMatch, root)

data SpaceRoutes = HomePage | RegisterPage

instance showSpaceRoutes :: Show SpaceRoutes where
  show (HomePage) = "/"
  show (RegisterPage) = "/register"

spaceRoutes :: Match (Maybe SpaceRoutes)
spaceRoutes = Just <$> (root *> oneOf [
  (RegisterPage <$ lit "register"),
  HomePage <$ optionalMatch (lit "#about_us")
] <* end) <|> pure Nothing
