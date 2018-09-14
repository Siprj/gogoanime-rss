{-# LANGUAGE DisambiguateRecordFields #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeOperators #-}

module DataModel.Type.Feed
    ( Feed(..)
    , SetFeed(..)
    , Feed'(..)
    , Kwa(..)
    )
  where

import Data.Data (Data)
import Data.Eq (Eq)
import Data.Int (Int)
import Data.SafeCopy
    ( Migrate(MigrateFrom, migrate)
    , deriveSafeCopy
    , extension
    )
import Data.Text (Text)
import Data.Maybe (Maybe)
import Data.Time (UTCTime)
import Data.Typeable (Typeable)
import GHC.Generics (Generic)
import Network.URI (URI)
import Text.Show (Show)
import Text.Read (Read)

import DataModel.OrphanInstances ()
import DataModel.Type.Old.Feed
    ( Feed_v0(Feed_v0, name_v0, url_v0, date_v0, imgUrl_v0)
    , SetFeed_v0(SetFeed_v0, setFeedName_v0, setFeedUrl_v0, setFeedImgUrl_v0)
    )

import DataModel.Type.TH (genData)
import qualified DataModel.Type.TH as TH (TypeVariable(Identity, Proxy, DontModify))


data Feed = Feed
    { name :: Text
    , url :: URI
    , date :: UTCTime
    , imgUrl :: URI
    , episodeNumber :: Int
    }
  deriving (Eq, Typeable, Generic, Data, Show)

$(deriveSafeCopy 1 'extension ''Feed)

instance Migrate Feed where
    type MigrateFrom Feed = Feed_v0
    migrate Feed_v0{..} = Feed
        { name = name_v0
        , url = url_v0
        , imgUrl = imgUrl_v0
        , date = date_v0
        , episodeNumber = 0
        }

data SetFeed = SetFeed
    { setFeedName :: Text
    , setFeedUrl :: URI
    , setFeedImgUrl :: URI
    , setFeedEpisodeNumber :: Int
    }

instance Migrate SetFeed where
    type MigrateFrom SetFeed = SetFeed_v0
    migrate SetFeed_v0{..} = SetFeed
        { setFeedName = setFeedName_v0
        , setFeedUrl = setFeedUrl_v0
        , setFeedImgUrl = setFeedImgUrl_v0
        , setFeedEpisodeNumber = 0
        }

newtype Kwa a = Kwa a

--data (a :/ b) c = (:/)
--    { pokpoku1 :: a
--    , pokpoku2 :: b
--    , pokpoku3 :: c
--    }

data Feed' f c a b d e g h = Feed'
    { name :: a Text
    , url :: c URI
    , blabla :: g h
    , date :: b UTCTime
    , imgUrl :: a URI
    , ahoj :: Text
    , episodeNumber :: a Int
    , kwa :: c (Kwa d)
    }

[genData|
data Ahojda a b c d e = Ahojda
    { ahoj1 :: a URI
    , ahoj2 :: b Int
    , ahoj3 :: a (Maybe e)
    , ahoj4 :: b Text
    }
  deriving (Show, Eq)

~~~

alias Ahojda Maybe Proxy DontModify DontModify DontModify: Ahojda => GetAhojda

conversion setAhojdaToGetAhojda = SetAhojda -> GetAhojda
conversion getAhojdaToSetAhojda = GetAhojda -> SetAhojda
|]
-- [genData|
-- data (Eq a, Show b) => forall a. Ahojda a b c d e = Ahojda
--     { ahoj1 :: (a -> d)
--     , ahoj2 :: b Int
--     , ahoj3 :: c (URI e)
--     , ahoj4 :: Maybe Text
--     }
--   deriving (Show, Read, Eq)
--
-- ~~~
--
-- alias Ahojda Maybe Identity : Ahojda => GetAhojda
--
-- conversion setAhojdaToGetAhojda = SetAhojda -> GetAhojda
-- conversion getAhojdaToSetAhojda = GetAhojda -> SetAhojda
-- |]


--  data Kwa a b c = Kwa
--      { kwa1 :: a Int
--      , kwa2 :: b Text
--      , kwa3 :: c URI
--      }
--    deriving(Eq, Show, Read)

$(deriveSafeCopy 1 'extension ''SetFeed)
