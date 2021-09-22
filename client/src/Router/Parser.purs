module Router.Parser (spaceRoutes, SpaceRoutes(..), prettyPrint) where

import Prelude

import Control.Alt ((<|>))
import Data.Array.NonEmpty.Internal (NonEmptyArray(..))
import Data.BookingsSearch (BookingsSearch, mapToBookingsSearch, toBookingsSearch)
import Data.Foldable (oneOf)
import Data.Maybe (Maybe(..))
import Routing.Match (Match, end, lit, optionalMatch, params, root)
import Test.QuickCheck (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (Gen)
import Test.QuickCheck.Gen as Gen

data SpaceRoutes = HomePage | RegisterPage | BookingsPage (Maybe BookingsSearch) | AccountPage

instance showSpaceRoutes :: Show SpaceRoutes where
  show (HomePage) = "HomePage"
  show (RegisterPage) = "RegisterPage"
  show (BookingsPage v) = "BookingsPage " <> show v
  show AccountPage = "AccountPage"

derive instance eqSpaceRoutes :: Eq SpaceRoutes
prettyPrint :: SpaceRoutes -> String
prettyPrint HomePage = "/"
prettyPrint RegisterPage = "/register"
prettyPrint (BookingsPage Nothing) = "/bookings"
prettyPrint (BookingsPage (Just {origin, destination, outbound_date, inbound_date})) = 
  "/bookings" <> "?origin=" <> origin <>
  "&destination=" <> destination <>
  "&outbound_date=" <> outbound_date <>
  "&inbound_date=" <> inbound_date
prettyPrint AccountPage = "/account"

instance arbSpaceRoutes :: Arbitrary SpaceRoutes where
  arbitrary = Gen.oneOf $ NonEmptyArray 
    [ pure HomePage
    , pure RegisterPage
    , BookingsPage <$> arbBookingsSearch
    , pure AccountPage
    ] where
      arbBookingsSearch :: Gen (Maybe BookingsSearch)
      arbBookingsSearch =  Gen.oneOf $ NonEmptyArray
        [ ((Just <<< toBookingsSearch) <$> arbitrary)
        , pure Nothing
        ]

spaceRoutes :: Match (Maybe SpaceRoutes)
spaceRoutes = Just <$> (root *> oneOf [
  (RegisterPage <$ lit "register"),
  AccountPage <$ lit "account",
  BookingsPage <$> (lit "bookings" *> (join <$> optionalMatch (mapToBookingsSearch <$> params))),
  HomePage <$ optionalMatch (lit "#about_us")
] <* end) <|> pure Nothing
