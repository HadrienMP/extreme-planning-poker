module Pure 
    ( CitizenId
    , CardCode
    , Ballot
    , Nation
    , Ballots
    , Poll
    , EnlistError(..)
    , initPoll
    , enlist
    , vote
    , cancelVote
    )
    where

import Data.Set as Set 
import Data.Map (Map, insert, delete, empty)
import Data.Result (Result(..))

type CitizenId = String
type CardCode = String
type Ballot = 
    { citizen :: CitizenId
    , card :: CardCode
    }

type Nation = Set.Set CitizenId
type Ballots = Map CitizenId CardCode
type Poll = 
    { nation :: Nation
    , ballots :: Ballots
    }

data EnlistError = DuplicatedName 

enlist :: CitizenId -> Poll -> Result EnlistError Poll
enlist citizen state =
    case Set.member citizen state.nation of
         true -> Ok state { nation = Set.insert citizen state.nation }
         _ -> Error DuplicatedName 

vote :: Ballot -> Poll -> Poll
vote ballot state =
    state { ballots = insert ballot.citizen ballot.card state.ballots }

cancelVote :: CitizenId -> Ballots -> Ballots
cancelVote = delete

initPoll :: Poll
initPoll = 
    { nation : Set.empty
    , ballots : empty
    }
