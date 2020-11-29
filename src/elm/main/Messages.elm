module Messages exposing (..)

import Http
import Json.Decode
import Model.Ballots as Ballots exposing (Ballot, Ballots)
import Error as Error
import Model.Nation as Nation exposing (Citizen, CitizenId, Nation)
import Time exposing (Posix)

type alias State =
    { nation: Nation
    , ballots : Ballots
    }


stateDecoder : Json.Decode.Decoder State
stateDecoder =
    Json.Decode.map2
        State
        (Json.Decode.field "voters" Nation.decoder)
        (Json.Decode.field "votes" Ballots.decoder)

type Msg
    = CmdResp (Result Http.Error ())
    | Sync State
    | KickedOut String

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
    | PollClosed
    | Start
    | PollStarted

    | CitizenLeft CitizenId