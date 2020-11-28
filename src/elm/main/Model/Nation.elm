module Model.Nation exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode as D exposing (Decoder)
import Json.Encode as Encode
import MD5
import SHA1

type alias CitizenId = String
type alias Citizen =
    { id : CitizenId
    , name : String
    }
type alias Nation = Dict CitizenId Citizen

enlist : Citizen -> Nation -> Nation
enlist citizen nation = Dict.insert citizen.id citizen nation

remove : CitizenId -> Nation -> Nation
remove citizen nation = Dict.remove citizen nation

citizens : Nation -> List Citizen
citizens nation = Dict.values nation

citizenHtml : Citizen -> List (Html a) -> Html a
citizenHtml citizen children =
    div [class "citizen"]
        ([ p [] [text citizen.name] ] ++ children)

encodeCitizen : Citizen -> Encode.Value
encodeCitizen citizen =
    Encode.object
        [ ("id", Encode.string citizen.id)
        , ("name", Encode.string citizen.name)
        ]

citizenDecoder : Decoder Citizen
citizenDecoder = D.map2 Citizen (D.field "id" D.string) (D.field "name" D.string)

decoder : Decoder Nation
decoder = D.dict citizenDecoder

footprint : Nation -> String
footprint nation =
    Dict.values nation
    |> List.sortBy .id
    |> List.map (\citizen -> citizen.id ++ citizen.name)
    |> List.foldr (++) ""