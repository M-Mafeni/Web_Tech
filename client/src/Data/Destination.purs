module Data.Destination (Destination, decodeDestinationJson, getDestinations) where

import Prelude
import Affjax as Ax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Data.Argonaut (Json, JsonDecodeError, decodeJson)
import Data.Argonaut.Decode.Decoders (decodeArray)
import Data.Either (Either(..))
import Effect.Aff (Aff)

type Destination
  = { id :: Int
    , name :: String
    }

decodeDestinationJson :: Json -> Either JsonDecodeError Destination
decodeDestinationJson = decodeJson


getDestinations :: Aff (Either String (Array Destination))
getDestinations = do
  responseJson <- Ax.get ResponseFormat.json "/api/destination"
  case responseJson of
    Left err -> do
      pure $ Left $ "an Error occured while getting the destinations" <> Ax.printError err
    Right { body, status, statusText } -> do
      case status of
        (StatusCode 200) -> do
          let
            destinationJson = decodeArray decodeDestinationJson body
          case destinationJson of
            Left err -> pure $ Left $ "Failed to Parse Response" <> show err
            Right destinations -> pure $ Right destinations
        _ -> pure $ Left $ statusText
