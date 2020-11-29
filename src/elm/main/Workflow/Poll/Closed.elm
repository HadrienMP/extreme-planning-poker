module Workflow.Poll.Closed exposing (..)

import Http
import Model.Ballots as Ballots exposing (Ballots)
import Model.Context exposing (Context, reset)
import Model.Deck as Deck exposing (Card, Deck)
import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (id)
import Model.Model as Model exposing (Model, Poll(..), ConnectionState(..))
import Model.Nation as Nation exposing (Citizen, Nation, citizenHtml)
import OtherHtml exposing (startButton)

-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Context -> (Model.ConnectionState, Cmd Msg)
update msg context =
    case msg of
        Start ->
            ( Connected context Closed
            , start )
        PollStarted ->
            ( Connected (reset context) (Open Nothing)
            , Cmd.none )
        _ ->
            ( Connected context Closed
            , Cmd.none )

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
    case model.connectionState of
        Connected context Closed ->
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