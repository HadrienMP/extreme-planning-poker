module Messages exposing (..)

import Http
import Model.Ballots exposing (Ballot, Ballots)
import Model.Nation exposing (Citizen, Nation)
import Time

type Msg
    = Error String
    | CmdResp (Result Http.Error ())
    | Tick Time.Posix
    | Sync (Nation, Ballots)

    | UpdateName String
    | GeneratedId String

    | Enlist
    | Enlisted Citizen


    | NationUpdated (Result Http.Error Nation)
    | Vote Ballot
    | VoteAccepted Ballot
    | Cancel Citizen
    | VoteCancelled Citizen

    | Close
    | PollCLosed
    | Start
    | PollStarted

    | CitizenLeft Citizen