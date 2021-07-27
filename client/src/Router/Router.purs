module Router (
  RouterContextValue,
  RouterContext,
  mkRouterContext,
  mkRouterProvider,
  useRouterContext,
  component,
  Component
) where
 -- Code adapted from routing example in thepurescript cookbook
 -- https://github.com/JordanMartinez/purescript-cookbook/blob/master/recipes/RoutingPushReactHooks/src/Main.purs

import Prelude

import Control.Monad.Reader (ReaderT(..), ask)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Partial.Unsafe as Partial.Unsafe
import React.Basic.Hooks (Hook, JSX, ReactContext, Render, UseContext)
import React.Basic.Hooks as R
import Router.Parser (SpaceRoutes(..), spaceRoutes)
import Routing.PushState (PushStateInterface, makeInterface, matches)

-- | Note that we are not using `React.Basic.Hooks.Component` here, replacing it
-- | instead with a very similar type, that has some extra "environment"
-- | provided by `ReaderT` (namely the `RouterContext` that we need to pass to
-- | `useRouterContext`). By using `ReaderT` we can avoid explicitly threading
-- | the context through to all the components that use it, instead we can just
-- | use `ask` to access it as needed.
type Component props
  = ReaderT RouterContext Effect (props -> JSX)

component ::
  forall props hooks.
  String -> (props -> Render Unit hooks JSX) -> Component props
component name render = ReaderT \_ -> R.component name render

type RouterContextValue
  = { route :: Maybe SpaceRoutes
    , nav :: PushStateInterface
    }

type RouterContext = ReactContext (Maybe RouterContextValue)

mkRouterContext :: Effect RouterContext
mkRouterContext = R.createContext Nothing

useRouterContext ::
  RouterContext ->
  Hook (UseContext (Maybe RouterContextValue)) RouterContextValue
useRouterContext routerContext = R.do
  maybeContextValue <- R.useContext routerContext
  pure case maybeContextValue of
    -- If we have no context value from a provider, we throw a fatal error
    Nothing ->
      Partial.Unsafe.unsafeCrashWith
        "useContext can only be used in a descendant of \
        \the corresponding context provider component"
    Just contextValue -> contextValue

mkRouterProvider :: Component (Array JSX)
mkRouterProvider = do
  routerContext <- ask
  nav <- liftEffect makeInterface
  component "Router" \children -> R.do
    let
      routerProvider = R.provider routerContext
    route /\ setRoute <- R.useState' (Just HomePage)
    R.useEffectOnce do
      nav
        # matches spaceRoutes \_ newRoute -> do
            setRoute newRoute
    pure (routerProvider (Just { nav, route }) children)

