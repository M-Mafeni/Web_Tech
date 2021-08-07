module Data.BookingsSearch (BookingsSearch, BookingsSearchImpl, toBookingsSearch, mapToBookingsSearch) where

import Prelude

import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.String (joinWith, length)
import Data.String.Gen (genAlphaString)
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

newtype Date = Date String
date :: Date -> String
date (Date s) = s

instance arbDate :: Arbitrary Date where
  arbitrary =  Date <$> (combineWithDashes <$> year <*> month <*> day) where
    year = show <$> Gen.chooseInt 1000 9999
    month = (padWithZero <<< show) <$> Gen.chooseInt 1 12
    day = (padWithZero <<< show) <$> Gen.chooseInt 1 12
    padWithZero x = if length x == 1 then "0" <> x else x
    combineWithDashes x y z = x <> "-" <> y <> "-" <> z

instance arbBookingSearchImpl :: Arbitrary BookingsSearchImpl where
  arbitrary = BookingsSearchImpl <$> genAlphaString <*> genAlphaString <*> (date <$> arbitrary) <*> (date <$> arbitrary)

type BookingsSearch
  = { origin :: String
    , destination :: String
    , outbound_date :: String
    , inbound_date :: String
    }

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
