module Messages exposing (..)

import Http
import Model.Ballots exposing (Ballot)
import Model.Nation exposing (Citizen, Nation)

type Msg
    = Error String
    | CmdResp (Result Http.Error ())

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

    | Leaving
    | CitizenLeft Citizen