module Async.Request (get) where

import Prelude
import Affjax as Ax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Data.Argonaut (Json, JsonDecodeError)
import Data.Either (Either(..))
import Effect.Aff (Aff)

type Error
  = String

type URL
  = String

type JsonDecoder a
  = Json -> Either JsonDecodeError a

get :: forall a. URL -> JsonDecoder a -> Aff (Either String a)
get url decoder = do
  responseJson <- Ax.get ResponseFormat.json url
  case responseJson of
    Left err -> pure $ Left ("GET " <> url <> " Error: " <> Ax.printError err)
    Right { body, status, statusText } -> do
      case status of
        (StatusCode 200) -> do
          let
            jsonValue = decoder body
          case jsonValue of
            Left err -> pure $ Left $ "Failed to Parse Response: " <> show err
            Right val -> pure $ Right val
        _ -> pure $ Left $ statusText
