module Common exposing (..)


import Http
import Json.Decode
import Json.Encode
import Messages exposing (Msg(..))
import Model.Ballots as Ballots
import Model.Model as Model exposing (..)
import Model.Nation as Nation exposing (Citizen)
import SHA1

sendHeartbeat : Context -> Cmd Msg
sendHeartbeat context =
    Http.post
    { url = "/nation/alive"
    , body = Http.jsonBody (heartbeat context)
    , expect = Http.expectWhatever CmdResp
    }

heartbeat: Context -> Json.Encode.Value
heartbeat context = Json.Encode.object
    [ ("citizen",   Nation.encodeCitizen context.me)
    , ("footprint", Model.footprint context
                    |> SHA1.toHex
                    |> Json.Encode.string)
    ]

stateDecoder : Json.Decode.Decoder Messages.State
stateDecoder =
    Json.Decode.map2
        Messages.State
        (Json.Decode.field "nation" Nation.decoder)
        (Json.Decode.field "ballots" Ballots.decoder)