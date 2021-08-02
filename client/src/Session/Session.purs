module Session 
  ( Session
  , SessionContext
  , SessionResponse
  , mkSessionContext
  , useSessionContext
  , getSession
  , toSession) where

import Prelude

import Affjax as Ax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Data.Argonaut (decodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Partial.Unsafe as Partial.Unsafe
import React.Basic (ReactContext)
import React.Basic.Hooks (Hook, UseContext)
import React.Basic.Hooks as React

type SessionResponse = {
  isLoggedIn :: Maybe Boolean,
  isAdmin :: Maybe Boolean
}

type Session = {
  isLoggedIn :: Boolean,
  isAdmin :: Boolean
}

type SessionContext = ReactContext (Maybe Session)

mkSessionContext :: Effect SessionContext
mkSessionContext = React.createContext Nothing

useSessionContext :: SessionContext -> Hook (UseContext (Maybe Session)) Session
useSessionContext sessionContext = React.do
  maybeSession <- React.useContext sessionContext
  pure case maybeSession of
    Nothing ->
      Partial.Unsafe.unsafeCrashWith
        "useContext can only be used in a descendant of \
        \the corresponding context provider component"
    Just session -> session

getSession :: Aff (Either String SessionResponse)
getSession = do
  responseJson <- Ax.get ResponseFormat.json "/session"
  case responseJson of
    Left err -> do
      pure $ Left $ "an Error occured while getting the session " <> Ax.printError err
    Right {body, status, statusText} -> do
      if status == (StatusCode 200)
      then do
        let sessionJson = decodeJson body
        case sessionJson of
          Left err -> do
             pure $ Left $ "Failed to Parse Response" <> show err
          Right val -> pure $ Right val
      else do
        pure $ Left $ statusText

toSession :: SessionResponse -> Session
toSession {isLoggedIn, isAdmin} = {
  isLoggedIn: fromMaybe false isLoggedIn,
  isAdmin: fromMaybe false isAdmin
}