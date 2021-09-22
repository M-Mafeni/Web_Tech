module Data.User (User) where

import Data.Ticket (Ticket)

type User
  = { id :: Int
    , email :: String
    , first_name :: String
    , last_name :: String
    , address :: String
    , isAdmin :: Boolean
    , tickets :: Array Ticket
    }
