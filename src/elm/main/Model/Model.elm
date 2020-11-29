module Model.Model exposing (..)

import Messages exposing (State)
import Model.Ballots exposing (Ballot, Ballots)
import Model.Context exposing (Context, contextFrom)
import Error exposing (Errors)
import Model.Nation exposing (Citizen, CitizenId, Nation)

type Poll = Open (Maybe Ballot) | Closed

type ConnectionState = Guest CitizenId String | Connected Context Poll

type alias Model =
    { errors: Errors
    , connectionState: ConnectionState
    }

openFrom : Citizen -> State -> Model
openFrom citizen state = Model Error.empty (Connected (contextFrom citizen state) (Open Nothing))