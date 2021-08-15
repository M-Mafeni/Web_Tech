module Test.ConfirmationPage where

import Prelude

import Components.ConfirmationPage (ConfirmationPageProps)
import Data.Ticket (fromFormattedticket)
import Effect (Effect)
import Foreign (unsafeFromForeign, unsafeToForeign)
import Test.QuickCheck (quickCheck, (<?>))

runConfirmationPageTests :: Effect Unit
runConfirmationPageTests = do
  quickCheck \t1 t2 ->
    -- Check whether props can be parsed to and from using the foreign interface
    let
      props :: ConfirmationPageProps
      props = {inboundTicket: fromFormattedticket t1, outboundTicket: fromFormattedticket t2}
      decoded :: ConfirmationPageProps
      decoded = (unsafeFromForeign (unsafeToForeign props))
    in eq props decoded <?> ("Failed to Parse " <> show props)