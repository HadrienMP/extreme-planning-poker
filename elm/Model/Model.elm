module Model.Model exposing (..)

import Model.Ballots as Ballots exposing (Ballot, Ballots)
import Model.Deck exposing (Deck)
import Model.Decks as Decks
import Model.Nation as Nation exposing (Citizen, CitizenId, Nation)
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

type Model
    = Guest CitizenId String
    | Open OpenModel
    | Closed Context

emptyOpen : Citizen -> Model
emptyOpen citizen = Open (OpenModel (emptyContext citizen) Nothing)

emptyContext : Citizen -> Context
emptyContext citizen =
    { deck= Decks.fwg
    , nation= Nation.empty
    , ballots= Ballots.empty
    , me = citizen
    , updatedName = citizen.name
    }

rename : Context -> Context
rename context =
    { context
    | nation = context.nation |> Nation.rename context.me.id context.updatedName
    , me = Citizen context.me.id context.updatedName
    }

updateName : Context -> String -> Context
updateName context name = { context | updatedName = name }

enlist : Context -> Citizen -> Context
enlist context citizen = { context | nation = Nation.enlist citizen context.nation }

updateNation : Context -> Nation -> Context
updateNation context nation = { context | nation = nation }

vote : Context -> Ballot -> Context
vote context newBallot = { context | ballots = Ballots.add newBallot context.ballots }

cancelVote : Context -> Citizen -> Context
cancelVote context citizen = { context | ballots = Ballots.remove citizen.id context.ballots }

reset : Context -> Context
reset context = { context | ballots = Ballots.empty }