port module Workflow.Guest exposing (..)
import Messages exposing (Msg(..), stateDecoder)
import Http exposing (Error(..))
import Error exposing (timeError)
import Model.Model exposing (Model, ConnectionState(..))
import Model.Nation as Nation exposing (Citizen, CitizenId)
import Tools
import Workflow.Connected as Connected

port connectSse : String -> Cmd msg

-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> CitizenId -> String -> (ConnectionState, Cmd Msg)
update msg id name =
    case msg of
        Enlist ->
            ( Guest id name
            , serverEnlist (Citizen id name))
        GeneratedId generated ->
            ( Guest generated name
            , connectSse generated)
        Enlisted response ->
            case response of
                Err (BadStatus _) ->
                    ( Guest id name
                    , timeError "This name is taken, please try another" |> Cmd.map ErrorMsg )
                Err error ->
                    ( Guest id name
                    , timeError (Tools.httpErrorToString error) |> Cmd.map ErrorMsg )
                Ok state ->
                    ( Connected.openFrom (Citizen id name) state
                    , Cmd.none )
        UpdateName newName  ->
            ( Guest id newName
            , Cmd.none )
        _ ->
            ( Guest id name
            , Cmd.none )

serverEnlist : Citizen -> Cmd Msg
serverEnlist citizen = Http.post
    { url = "/nation/enlist"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectJson Enlisted stateDecoder
    }