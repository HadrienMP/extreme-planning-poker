module Common exposing (..)


import Http
import Messages exposing (Msg(..))
import Model.Nation as Nation exposing (Citizen)

removeCitizen : Citizen -> Cmd Msg
removeCitizen citizen =
    Http.post
    { url = "/citizen/remove"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectWhatever CmdResp
    }