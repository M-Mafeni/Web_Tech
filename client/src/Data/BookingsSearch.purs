module Data.BookingsSearch (BookingsSearch, BookingsSearchImpl, toBookingsSearch, mapToBookingsSearch, getBookingTickets, makeBookingQueryString) where

import Prelude

import Async.Request as Request
import Data.Argonaut (decodeJson)
import Data.FormattedDate (date)
import Data.Either (Either)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.String (length)
import Data.String.Gen (genAlphaString)
import Data.Ticket (Tickets)
import Effect.Aff (Aff)
import Test.QuickCheck (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen as Gen

type Origin
  = String

type Destination
  = String

type Outbound
  = String

type Inbound
  = String

data BookingsSearchImpl
  = BookingsSearchImpl Origin Destination Outbound Inbound

instance arbBookingSearchImpl :: Arbitrary BookingsSearchImpl where
  arbitrary = BookingsSearchImpl <$> genAlphaString <*> genAlphaString <*> (date <$> arbitrary) <*> (date <$> arbitrary)

type BookingsSearch
  = { origin :: String
    , destination :: String
    , outbound_date :: String
    , inbound_date :: String
    }

type BookingsTickets
  = { outboundTickets :: Tickets
    , inboundTickets :: Tickets
    }

getBookingTickets :: BookingsSearch -> Aff (Either String BookingsTickets)
getBookingTickets bookingsSearch = Request.get url decodeJson
  where
  url = "/api/bookings" <> makeBookingQueryString bookingsSearch

makeBookingQueryString :: BookingsSearch -> String
makeBookingQueryString { origin, destination, outbound_date, inbound_date } =
  "?origin=" <> origin
    <> "&destination="
    <> destination
    <> "&outbound_date="
    <> outbound_date
    <> "&inbound_date="
    <> inbound_date

toBookingsSearchImpl :: Map String String -> Maybe BookingsSearchImpl
toBookingsSearchImpl params =
  BookingsSearchImpl
    <$> Map.lookup "origin" params
    <*> Map.lookup "destination" params
    <*> Map.lookup "outbound_date" params
    <*> Map.lookup "inbound_date" params

toBookingsSearch :: BookingsSearchImpl -> BookingsSearch
toBookingsSearch (BookingsSearchImpl origin destination outbound_date inbound_date) =
  { origin
  , destination
  , outbound_date
  , inbound_date
  }

mapToBookingsSearch :: Map String String -> Maybe BookingsSearch
mapToBookingsSearch params = toBookingsSearch <$> toBookingsSearchImpl params
