module Workflow.Guest exposing (..)
import Messages exposing (Msg(..))
import Model.Ballots as Ballots
import Model.Decks as Decks
import Model.Model as Model exposing (Context, Model(..))
import Http
import Model.Nation as Nation exposing (Citizen)


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
                Enlisted citizen -> (Model.emptyOpen citizen, loadNation)
                UpdateName newName  -> (Guest id newName, Cmd.none)
                _ -> (model, Cmd.none)
        _ -> (model, Cmd.none)

serverEnlist : Citizen -> Cmd Msg
serverEnlist citizen = Http.post
    { url = "/nation/enlist"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectWhatever CmdResp
    }

loadNation : Cmd Msg
loadNation = Http.get
    { url = "/nation"
    , expect = Http.expectJson NationUpdated Nation.decoder
    }