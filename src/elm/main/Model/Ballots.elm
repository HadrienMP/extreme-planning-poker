module Model.Ballots exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import MD5
import Model.Deck as Deck exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import Model.Nation exposing (Citizen, CitizenId)
import SHA1

type alias Ballot =
    { citizen : CitizenId
    , cardCode : CardCode
    }
type alias Ballots = Dict CitizenId CardCode

empty : Ballots
empty = Dict.fromList []

add : Ballot -> Ballots -> Ballots
add ballot ballots =
    Dict.insert ballot.citizen ballot.cardCode ballots

remove : CitizenId -> Ballots -> Ballots
remove citizen ballots =
    Dict.remove citizen ballots

hasVoted : Citizen -> Ballots -> Bool
hasVoted citizen ballots = Dict.member citizen.id ballots

cardCodeOf : Citizen -> Ballots -> Maybe CardCode
cardCodeOf citizen ballots = Dict.get citizen.id ballots

ballotHtml : Maybe Card -> Html a
ballotHtml maybe =
    case maybe of
        Nothing -> div [class "slot"] []
        Just card -> Deck.cardHtml card

encode : Ballot -> Encode.Value
encode ballot =
    Encode.object
        [ ("citizen", Encode.string ballot.citizen)
        , ("cardCode", Encode.string ballot.cardCode)
        ]

decoder : Decode.Decoder Ballots
decoder = Decode.dict Decode.string

ballotDecoder : Decode.Decoder Ballot
ballotDecoder = Decode.map2 Ballot (Decode.field "citizen" Decode.string) (Decode.field "ballot" Decode.string)

footprint : Ballots -> String
footprint ballots =
    Dict.toList ballots
    |> List.sortBy Tuple.first
    |> List.map (\ballot -> (Tuple.first ballot) ++ (Tuple.second ballot))
    |> List.foldr (++) ""