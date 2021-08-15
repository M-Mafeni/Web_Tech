module Data.FormattedDate where

import Prelude

import Data.String (length)
import Test.QuickCheck (class Arbitrary)
import Test.QuickCheck.Gen as Gen

newtype FormattedDate
  = FormattedDate String

date :: FormattedDate -> String
date (FormattedDate s) = s

instance arbDate :: Arbitrary FormattedDate where
  arbitrary = FormattedDate <$> (combineWithDashes <$> year <*> month <*> day)
    where
    year = show <$> Gen.chooseInt 1000 9999

    month = (padWithZero <<< show) <$> Gen.chooseInt 1 12

    day = (padWithZero <<< show) <$> Gen.chooseInt 1 12

    padWithZero x = if length x == 1 then "0" <> x else x

    combineWithDashes x y z = x <> "-" <> y <> "-" <> z
