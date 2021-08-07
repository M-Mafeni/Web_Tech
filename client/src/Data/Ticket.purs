module Data.Ticket where

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

type Tickets = Array Ticket
