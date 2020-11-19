module Messages exposing (..)

import Http
import Model.Ballots exposing (Ballot, Ballots)
import Model.Error exposing (Error)
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

    | ErrorMsg String
    | AddError Error
    | DeleteError Error

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