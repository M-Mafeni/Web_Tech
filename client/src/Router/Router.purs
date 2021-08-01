module Router (
  RouterContextValue,
  RouterContext,
  mkRouterContext,
  useRouterContext) where
 -- Code adapted from routing example in thepurescript cookbook
 -- https://github.com/JordanMartinez/purescript-cookbook/blob/master/recipes/RoutingPushReactHooks/src/Main.purs

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Partial.Unsafe as Partial.Unsafe
import React.Basic.Hooks (Hook, ReactContext, UseContext)
import React.Basic.Hooks as R
import Router.Parser (SpaceRoutes)
import Routing.PushState (PushStateInterface)

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

