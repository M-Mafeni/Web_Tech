module Data.User (User, getCurrentUser) where

import Async.Request as Request
import Data.Argonaut (decodeJson)
import Data.Either (Either)
import Data.Ticket (Ticket)
import Effect.Aff (Aff)

type User
  = { id :: Int
    , email :: String
    , first_name :: String
    , last_name :: String
    , address :: String
    , isAdmin :: Boolean
    , tickets :: Array Ticket
    }

getCurrentUser :: Aff (Either String User)
getCurrentUser = Request.get "/api/user/currentUser" decodeJson
