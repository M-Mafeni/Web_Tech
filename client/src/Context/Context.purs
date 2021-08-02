module Context (
  Component,
  Context,
  component,
  mkRouterProvider,
  mkSessionProvider) where

import Prelude

import Control.Monad.Reader (ReaderT(..), ask)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import React.Basic (JSX)
import React.Basic.Hooks (Render)
import React.Basic.Hooks as React
import Router (RouterContext)
import Router.Parser (SpaceRoutes(..), spaceRoutes)
import Routing.PushState (makeInterface, matches)
import Session (SessionContext, getSession)

-- | Note that we are not using `React.Basic.Hooks.Component` here, replacing it
-- | instead with a very similar type, that has some extra "environment"
-- | provided by `ReaderT` (namely the `RouterContext` that we need to pass to
-- | `useRouterContext`). By using `ReaderT` we can avoid explicitly threading
-- | the context through to all the components that use it, instead we can just
-- | use `ask` to access it as needed.
type Component props
  = ReaderT Context Effect (props -> JSX)

type Context = {
  routerContext :: RouterContext,
  sessionContext :: SessionContext
}

component ::
  forall props hooks.
  String -> (props -> Render Unit hooks JSX) -> Component props
component name render = ReaderT \_ -> React.component name render

mkRouterProvider :: Component (Array JSX)
mkRouterProvider = do
  {routerContext} <- ask
  nav <- liftEffect makeInterface
  component "Router" \children -> React.do
    let
      routerProvider = React.provider routerContext
    route /\ setRoute <- React.useState' (Just HomePage)
    React.useEffectOnce do
      nav
        # matches spaceRoutes \_ newRoute -> do
            setRoute newRoute
    pure (routerProvider (Just { nav, route }) children)

mkSessionProvider :: Component (Array JSX)
mkSessionProvider = do
  {sessionContext} <- ask
  component "Session" \children -> React.do
    let sessionProvider = React.provider sessionContext
    session /\ setSession <- React.useState' {isLoggedIn: Nothing, isAdmin: Nothing}
    React.useEffectOnce do
      flip runAff_ getSession $ \possValue -> do
        case possValue of
          Left err -> throw $ show err
          Right eitherErrSession -> case eitherErrSession of
            Left err -> throw $ show err
            Right sessionVal -> do
              setSession sessionVal
      pure mempty
    pure $ sessionProvider (Just session) children