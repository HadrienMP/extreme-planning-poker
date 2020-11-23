module Test.PureSpec where

import Prelude

import Test.Spec (describe, it, Spec, pending)
import Test.Spec.Assertions (shouldContain, shouldEqual)
import Data.Result (fromError, fromOk)

import Pure


pureSpec :: Spec Unit
pureSpec =
    describe "guests" do
        it "can enlist to become citizens" do
            let updated = fromOk $ enlist "Emma" initPoll
            updated.nation `shouldContain` "Emma" 
        pending "must have a unique name to enlist" do
            let error = fromError $ enlist "Emma" $ enlist "Emma" initPoll
            error `shouldEqual` DuplicatedName

