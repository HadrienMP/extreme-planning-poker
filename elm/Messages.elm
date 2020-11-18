module Messages exposing (..)

import Http
import Model.Ballots exposing (Ballot, Ballots)
import Model.Nation exposing (Citizen, Nation)
import Time

type alias State =
    { nation: Nation
    , ballots : Ballots
    }

type Msg
    = Error String
    | CmdResp (Result Http.Error ())
    | Tick Time.Posix
    | Sync State

    | UpdateName String
    | GeneratedId String

    | Enlist
    | Enlisted Citizen

    | StateResponse (Result Http.Error State)
    | Vote Ballot
    | VoteAccepted Ballot
    | Cancel Citizen
    | VoteCancelled Citizen

    | Close
    | PollCLosed
    | Start
    | PollStarted

    | CitizenLeft Citizen