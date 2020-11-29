module Workflow.Closed exposing (..)
import Common exposing (kickedOut)
import Http
import Model.Ballots as Ballots exposing (Ballots)
import Model.Deck as Deck exposing (Card, Deck)
import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (id)
import Error as Error
import Model.Model as Model exposing (Context, Model, Workflow(..))
import Model.Nation as Nation exposing (Citizen, Nation, citizenHtml)
import OtherHtml exposing (startButton)
import Tools

-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Context -> (Model.Workflow, Cmd Msg)
update msg context =
    case msg of
        KickedOut reason -> context.me |> kickedOut reason
        Sync state ->
            ( Model.sync state context |> Model.Closed
            , Error.timeError "Out of sync" |> Cmd.map ErrorMsg
            )
        CitizenLeft citizen ->
            if citizen == context.me.id then
                ( Model.Guest "" ""
                , Cmd.none )
            else
                ( Model.removeCitizen context citizen |> Model.Closed
                , Cmd.none )
        NewCitizen citizen ->
            ( Model.enlist context citizen |> Model.Closed
            , Cmd.none )
        Start -> (context |> Model.Closed, start)
        PollStarted ->
            ( Model.OpenModel (Model.reset context) Nothing |> Model.Open
            , Cmd.none)
        _ ->
            ( context |> Model.Closed
            , Cmd.none)

start : Cmd Msg
start =
    Http.post
    { url = "/poll/start"
    , body = Http.emptyBody
    , expect = Http.expectWhatever CmdResp
    }

-- ###################################################
-- VIEW
-- ###################################################

view : Model -> List (Html Msg)
view model =
    case model.workflow of
        Closed context ->
            [ div [id "nation"]
                  (  ballotsHtml context.nation context.ballots context.deck
                  ++ [ startButton ]
                  )
            ]
        _ -> []

ballotsHtml : Nation -> Ballots -> Deck -> List (Html Msg)
ballotsHtml nation ballots deck =
    Nation.citizens nation
    |> List.map (\citizen -> citizenHtml citizen [ballotHtml citizen ballots deck])

ballotHtml : Citizen -> Ballots -> Deck -> Html Msg
ballotHtml citizen ballots deck = Ballots.ballotHtml (getCard citizen ballots deck)

getCard : Citizen -> Ballots -> Deck -> Maybe Card
getCard citizen ballots deck =
    case Ballots.cardCodeOf citizen ballots of
        Just cardCode -> Deck.findBy cardCode deck
        Nothing -> Nothing