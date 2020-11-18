module Common exposing (..)


import Http
import Messages exposing (Msg(..))
import Model.Nation as Nation exposing (Citizen)

sendHeartbeat : Citizen -> Cmd Msg
sendHeartbeat citizen =
    Http.post
    { url = "/nation/alive"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectWhatever CmdResp
    }

