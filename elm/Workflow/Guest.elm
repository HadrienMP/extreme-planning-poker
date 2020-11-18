module Workflow.Guest exposing (..)
import Common
import Messages exposing (Msg(..))
import Model.Ballots as Ballots
import Model.Decks as Decks
import Model.Model as Model exposing (Context, Model(..))
import Http
import Model.Nation as Nation exposing (Citizen)
import Tools


-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case model of
        Guest id guest ->
            case msg of
                Enlist -> (model, serverEnlist (Citizen id guest))
                GeneratedId generated -> (Guest generated guest, Cmd.none)
                Enlisted response ->
                    case response of
                        Err e ->
                            ( Debug.log (Tools.httpErrorToString e) model
                            , Cmd.none )
                        Ok state ->
                            ( Model.openFrom (Citizen id guest) state
                            , Cmd.none )
                UpdateName newName  -> (Guest id newName, Cmd.none)
                _ -> (model, Cmd.none)
        _ -> (model, Cmd.none)

serverEnlist : Citizen -> Cmd Msg
serverEnlist citizen = Http.post
    { url = "/nation/enlist"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectJson Enlisted Common.stateDecoder
    }