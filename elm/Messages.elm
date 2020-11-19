module Messages exposing (..)

import Http
import Model.Ballots exposing (Ballot, Ballots)
import Model.Error as Error exposing (Error)
import Model.Nation exposing (Citizen, Nation)
import Time exposing (Posix)

type alias State =
    { nation: Nation
    , ballots : Ballots
    }

type Msg
    = CmdResp (Result Http.Error ())
    | Tick Time.Posix
    | Sync State
    | HeartbeatResp (Result Http.Error ())

    | ErrorMsg Error.Msg

    | UpdateName String
    | GeneratedId String

    | Enlist
    | Enlisted (Result Http.Error State)
    | NewCitizen Citizen

    | Vote Ballot
    | VoteAccepted Ballot
    | Cancel Citizen
    | VoteCancelled Citizen

    | Close
    | PollCLosed
    | Start
    | PollStarted

    | CitizenLeft Citizen