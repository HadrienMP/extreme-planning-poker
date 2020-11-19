module Workflow.Guest exposing (..)
import Common exposing (addError)
import Messages exposing (Msg(..))
import Http exposing (Error(..))
import Model.Model as Model exposing (Model, Workflow(..))
import Model.Nation as Nation exposing (Citizen)
import Task exposing (Task, perform)
import Time exposing (now)
import Tools


-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case model.workflow of
        Guest id guest ->
            case msg of
                Enlist ->
                    ( model
                    , serverEnlist (Citizen id guest))
                GeneratedId generated ->
                    ( Guest generated guest |> Model model.errors
                    , Cmd.none)
                Enlisted response ->
                    case response of
                        Err (BadStatus _) ->
                            ( model
                            , addError "This name is taken, please try another" )
                        Err error ->
                            ( model
                            , addError (Tools.httpErrorToString error) )
                        Ok state ->
                            ( Model.openFrom (Citizen id guest) state
                            , Cmd.none )
                UpdateName newName  ->
                    ( Guest id newName |> Model model.errors
                    , Cmd.none )
                _ -> (model, Cmd.none)
        _ -> (model, Cmd.none)

serverEnlist : Citizen -> Cmd Msg
serverEnlist citizen = Http.post
    { url = "/nation/enlist"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectJson Enlisted Common.stateDecoder
    }