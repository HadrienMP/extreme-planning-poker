module Model.Model exposing (..)

import Messages exposing (State)
import Model.Ballots as Ballots exposing (Ballot, Ballots)
import Model.Deck exposing (Deck)
import Model.Decks as Decks
import Model.Error exposing (Errors)
import Model.Nation as Nation exposing (Citizen, CitizenId, Nation)
import SHA1

type alias Context =
    { deck: Deck
    , nation: Nation
    , ballots: Ballots
    , me: Citizen
    , updatedName: String
    }

type alias OpenModel =
    { context: Context
    , ballot: Maybe Ballot
    }

type Workflow
    = Guest CitizenId String
    | Open OpenModel
    | Closed Context

type alias Model =
    { errors: Errors
    , workflow: Workflow
    }



sync : State -> Context -> Context
sync state context =
    { context
    | nation = state.nation
    , ballots = state.ballots
    }

footprint : Context -> SHA1.Digest
footprint context =
    ((Nation.footprint context.nation), (Ballots.footprint context.ballots))
    |> Tuple.mapBoth SHA1.toHex SHA1.toHex
    |> (\t -> (Tuple.first t) ++ (Tuple.second t))
    |> SHA1.fromString

openFrom : Citizen -> State -> Model
openFrom citizen state = Model [] (Open (OpenModel (contextFrom citizen state) Nothing))

contextFrom : Citizen -> State -> Context
contextFrom citizen state =
    { deck= Decks.fwg
    , nation= state.nation
    , ballots= state.ballots
    , me = citizen
    , updatedName = citizen.name
    }


enlist : Context -> Citizen -> Context
enlist context citizen = { context | nation = Nation.enlist citizen context.nation }

removeCitizen : Context -> Citizen -> Context
removeCitizen context citizen = { context | nation = Nation.remove citizen context.nation }

vote : Context -> Ballot -> Context
vote context newBallot = { context | ballots = Ballots.add newBallot context.ballots }

cancelVote : Context -> Citizen -> Context
cancelVote context citizen = { context | ballots = Ballots.remove citizen.id context.ballots }

reset : Context -> Context
reset context = { context | ballots = Ballots.empty }