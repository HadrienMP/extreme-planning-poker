module Messages exposing (..)

import Http
import Model.Ballots exposing (Ballot, Ballots)
import Error as Error
import Model.Nation exposing (Citizen, CitizenId, Nation)
import Time exposing (Posix)

type alias State =
    { nation: Nation
    , ballots : Ballots
    }

type Msg
    = CmdResp (Result Http.Error ())
    | SendHeartbeat
    | HeartbeatResp (Result Http.Error ())
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