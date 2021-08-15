module Data.Ticket (Ticket, Tickets, FormattedTicket, fromFormattedticket) where

import Prelude
import Data.String.Gen (genAlphaString)
import Test.QuickCheck (class Arbitrary, arbitrary)

type Ticket
  = { id :: Int
    , o_date :: String
    , o_time :: String
    , origin_place :: String
    , d_date :: String
    , d_time :: String
    , destination_place :: String
    , price :: Number
    }

type Tickets
  = Array Ticket

type Date
  = String

type Time
  = String

type Place
  = String

data TicketImpl
  = TicketImpl Int Date Time Place Date Time Place Number

instance arbTicketImpl :: Arbitrary TicketImpl where
  arbitrary =
    TicketImpl
      <$> arbitrary
      <*> genAlphaString
      <*> genAlphaString
      <*> genAlphaString
      <*> genAlphaString
      <*> genAlphaString
      <*> genAlphaString
      <*> arbitrary

fromTicketImpl :: TicketImpl -> Ticket
fromTicketImpl (TicketImpl id_ o_date o_time origin_place d_date d_time destination_place price) =
  { id: id_
  , o_date
  , o_time
  , origin_place
  , d_date
  , d_time
  , destination_place
  , price
  }

newtype FormattedTicket
  = FormattedTicket Ticket

fromFormattedticket :: FormattedTicket -> Ticket
fromFormattedticket (FormattedTicket t) = t

instance arbFormattedTicket :: Arbitrary FormattedTicket where
  arbitrary = (FormattedTicket <<< fromTicketImpl) <$> arbitrary
