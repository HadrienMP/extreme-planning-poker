module Workflow.Closed exposing (..)
import Common
import Http
import Model.Ballots as Ballots exposing (Ballots)
import Model.Deck as Deck exposing (Card, Deck)
import Messages exposing (Msg(..))
import Model.Model as Model exposing (Context, Model(..))
import Html exposing (..)
import Html.Attributes exposing (id)
import Model.Nation as Nation exposing (Citizen, Nation, citizenHtml)
import OtherHtml exposing (enlistForm, startButton)

-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case model of
        Closed context ->
            case msg of
                Leaving -> (model, Common.removeCitizen context.me)
                CitizenLeft citizen ->
                    ( Closed (Model.removeCitizen context citizen)
                    , Cmd.none )
                Start -> (model, start)
                PollStarted ->
                    ( Open ( Model.OpenModel (Model.reset context) Nothing)
                    , Cmd.none)
                _ -> (model, Cmd.none)
        _ -> (model, Cmd.none)

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
    case model of
        Closed context ->
            [ enlistForm context.updatedName
            , div [id "nation"]
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