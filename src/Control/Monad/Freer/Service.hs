{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Control.Monad.Freer.Service
    ( IscCall(..)
    , ServiceChannel
    , createServiceChannel
    , runServiceChannel
    , runServiceEffect
    )
  where

import Control.Applicative ((<$>))
import Control.Concurrent.MVar (MVar, newEmptyMVar, takeMVar, putMVar)
import Control.Concurrent.STM.TChan (TChan, newTChanIO, writeTChan, readTChan)
import Control.Monad.Freer (Eff, Member, runNat)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.STM (atomically)
import Data.Function (($), (.))
import System.IO (IO)


class IscCall service where
    data ChannelData service :: * -> *
    get :: ChannelData service a -> service a
    put :: service a -> ChannelData service a

data ChannelContainer service where
    ChannelContainer
        :: forall a service. IscCall service
        => ChannelData service a
        -> MVar a
        -> ChannelContainer service

data ServiceChannel service where
    ServiceChannel
        :: IscCall service
        => TChan (ChannelContainer service)
        -> ServiceChannel service

createServiceChannel :: IscCall service => IO (ServiceChannel service)
createServiceChannel = ServiceChannel <$> newTChanIO

runServiceChannel
    :: (IscCall service, MonadIO m)
    => ServiceChannel service
    -> (forall a. (a -> m ()) -> service a -> m ())
    -> m ()
runServiceChannel schan@(ServiceChannel chan) f = do
    val <- liftIO $ atomically $ readTChan chan
    case val of
        ChannelContainer v resMVar -> f (liftIO . putMVar resMVar) $ get v
    runServiceChannel schan f

runServiceEffect
    :: forall effs service a
    . (Member IO effs, IscCall service)
    => ServiceChannel service
    -> Eff (service ': effs) a
    -> Eff effs a
runServiceEffect (ServiceChannel chan) = runNat go
  where
    go :: service s -> IO s
    go v = do
        respMVar <- newEmptyMVar
        atomically $ writeTChan chan (ChannelContainer (put v) respMVar)
        takeMVar respMVar
