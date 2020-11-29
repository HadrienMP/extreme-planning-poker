module Workflow.Poll.Open exposing (..)

import Http
import Model.Ballots as Ballots exposing (Ballot, hasVoted, Ballots)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model.Context as Context exposing (Context)
import Model.Model as Model exposing (Model, Poll(..))
import Model.Nation as Nation exposing (..)
import Model.Deck exposing (Card, Deck, cardHtml2)
import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Model.Nation exposing (Citizen, Nation)
import OtherHtml exposing (closeButton)


-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Context -> Maybe Ballot -> (Model.ConnectionState, Cmd Msg)
update msg context ballot =
    case msg of
        Vote newBallot ->
            ( Model.Connected context (Open (Just newBallot))
            , vote newBallot)
        VoteAccepted newBallot ->
            ( Model.Connected (Context.vote context newBallot) (Open ballot)
            , Cmd.none)
        Cancel citizen ->
            ( Model.Connected context (Open Nothing)
            , cancelVote citizen)
        VoteCancelled citizen ->
            ( Model.Connected (Context.cancelVote context citizen) (Open ballot)
            , Cmd.none)
        Close ->
            ( Model.Connected context (Open ballot)
            , close)
        PollClosed ->
            ( Model.Connected context Closed
            , Cmd.none)
        _ ->
            ( Model.Connected context (Open ballot)
            , Cmd.none)


vote : Ballots.Ballot -> Cmd Msg
vote ballot =
    Http.post
    { url = "/vote"
    , body = Http.jsonBody (Ballots.encode ballot)
    , expect = Http.expectWhatever CmdResp
    }

cancelVote : Citizen -> Cmd Msg
cancelVote citizen =
    Http.post
    { url = "/vote/cancel"
    , body = Http.jsonBody (Nation.encodeCitizen citizen)
    , expect = Http.expectWhatever CmdResp
    }

close : Cmd Msg
close =
    Http.post
    { url = "/poll/close"
    , body = Http.emptyBody
    , expect = Http.expectWhatever CmdResp
    }

-- ###################################################
-- VIEW
-- ###################################################

view : Model -> List (Html Msg)
view model =
    case model.connectionState of
        Model.Connected context (Open ballot) ->
            [ div [id "nation"]
                  (  votersHtml context.nation context.ballots
                  ++ [closeButton]
                  )
            , deckHtml context.deck context.me ballot]
        _ -> []

votersHtml : Nation -> Ballots -> List (Html Msg)
votersHtml nation ballots =
    Nation.citizens nation
    |> List.map (voterHtml ballots)

voterHtml : Ballots -> Citizen -> Html Msg
voterHtml ballots citizen =
    div [ class "citizen" ]
        [ p [] [text citizen.name]
        , div [classList [("slot", True), ("full", hasVoted citizen ballots)]] []
        ]

--
-- Deck
--

deckHtml : Deck -> Citizen -> Maybe Ballot -> Html Msg
deckHtml deck citizen ballot =
    div [id "deck"]
        ( deck |> List.map (\card -> cardHtml2 card ( cardAttributes card citizen ballot )))

cardAttributes : Card -> Citizen -> Maybe Ballot -> List (Attribute Msg)
cardAttributes card citizen maybeBallot =
    case maybeBallot of
        Just ballot ->
            if ballot.cardCode == card.code then
                [ class "card selected"
                , onClick (Cancel citizen)
                ]
            else
                notSelectedCardAttributes citizen card
        _ ->    notSelectedCardAttributes citizen card

notSelectedCardAttributes : Citizen -> Card -> List (Attribute Msg)
notSelectedCardAttributes citizen card =
    [ class "card"
    , onClick (Vote (Ballot citizen.id card.code))
    ]
