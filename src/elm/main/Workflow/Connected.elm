module Workflow.Connected exposing (..)

import Error
import Messages exposing (Msg(..), State)
import Model.Context as Context exposing (Context, contextFrom)
import Model.Model as Model exposing (ConnectionState(..), Poll(..))
import Model.Nation exposing (Citizen)
import Workflow.Poll.Closed as Closed
import Workflow.Poll.Open as Open

openFrom : Citizen -> State -> ConnectionState
openFrom citizen state = Connected (contextFrom citizen state) (Open Nothing)

update : Msg -> Context -> Poll -> (Model.ConnectionState, Cmd Msg)
update msg context poll =
    case msg of
        KickedOut reason ->
            ( Model.Guest context.me.id context.me.name
                , "You were kicked out by the server (" ++ reason ++ ")"
                    |> Error.timeError
                    |> Cmd.map ErrorMsg
                )
        Sync state ->
            ( Model.Connected (Context.sync state context) poll
            , Error.timeError "Out of sync" |> Cmd.map ErrorMsg
            )
        CitizenLeft citizen ->
            if citizen == context.me.id then
                ( Model.Guest "" ""
                , Cmd.none )
            else
                ( Model.Connected (Context.removeCitizen context citizen) poll
                , Cmd.none )
        NewCitizen citizen ->
            ( Model.Connected (Context.enlist context citizen) poll
            , Cmd.none )
        _ ->
            case poll of
                Open ballot -> Open.update msg context ballot
                Closed -> Closed.update msg context