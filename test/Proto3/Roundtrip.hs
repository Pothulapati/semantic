{-# LANGUAGE TypeApplications #-}

module Proto3.Roundtrip (spec) where

import SpecHelpers

import Data.Span
import qualified Data.ByteString.Lazy as L
import Data.Source
import Proto3.Suite
import qualified Proto3.Wire.Encode as E

shouldRoundtrip :: (Eq a, Show a, Message a) => a -> Expectation
shouldRoundtrip a = go a `shouldBe` Right a
  where go = fromByteString . L.toStrict . toLazyByteString

spec :: Spec
spec = parallel $ do
  describe "spans" $
    prop "roundtrips" $
      \sp -> shouldRoundtrip @Span sp

  describe "blobs" $ do
    it "should roundtrip given a Message instance" $ do
      let bl = Blob (fromUTF8 "puts 'hi'") "example.rb" Ruby
      shouldRoundtrip bl

  describe "languages" $ do
    -- If this test broke, it means you've probably added another 'Language'.
    -- Add it to the list of languages below and everything should be good,
    -- as long as you added it in a way that doesn't break prior Enum encodings.
    it "should match up with Enum declarations" $ do
      let go :: (Primitive f, MessageField f) => [f] -> [L.ByteString]
          go x = E.toLazyByteString . encodePrimitive (fieldNumber 0) <$> x
      let ints = [0..fromEnum (maxBound @Language)]
      let langs = [Unknown, Go, Haskell, Java, JavaScript, JSON,
                   JSX, Markdown, Python, Ruby, TypeScript, PHP]
      go ints `shouldBe` go langs
