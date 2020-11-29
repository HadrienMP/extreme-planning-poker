module Common exposing (..)


import Error
import Http
import Json.Decode
import Json.Encode
import Messages exposing (Msg(..))
import Model.Ballots as Ballots
import Model.Model as Model exposing (..)
import Model.Nation as Nation exposing (Citizen)

kickedOut : String -> Citizen -> (Workflow, Cmd Msg)
kickedOut reason citizen =
    ( Model.Guest citizen.id citizen.name
    , "You were kicked out by the server (" ++ reason ++ ")"
        |> Error.timeError
        |> Cmd.map ErrorMsg
    )

stateDecoder : Json.Decode.Decoder Messages.State
stateDecoder =
    Json.Decode.map2
        Messages.State
        (Json.Decode.field "voters" Nation.decoder)
        (Json.Decode.field "votes" Ballots.decoder)