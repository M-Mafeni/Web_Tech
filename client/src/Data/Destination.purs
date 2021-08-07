module Data.Destination (Destination, decodeDestinationJson, getDestinations) where

import Async.Request as Request
import Data.Argonaut (Json, JsonDecodeError, decodeJson)
import Data.Argonaut.Decode.Decoders (decodeArray)
import Data.Either (Either)
import Effect.Aff (Aff)

type Destination
  = { id :: Int
    , name :: String
    }

decodeDestinationJson :: Json -> Either JsonDecodeError Destination
decodeDestinationJson = decodeJson


getDestinations :: Aff (Either String (Array Destination))
getDestinations = Request.get "/api/destination" (decodeArray decodeDestinationJson) 