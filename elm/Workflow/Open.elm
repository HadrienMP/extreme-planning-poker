module Workflow.Open exposing (..)

import Common
import Http
import Model.Ballots as Ballots exposing (Ballot, hasVoted, Ballots)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model.Error as Error
import Model.Model as Model exposing (Model)
import Model.Nation as Nation exposing (..)
import Model.Deck exposing (Card, Deck, cardHtml2)
import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Model.Nation exposing (Citizen, Nation)
import OtherHtml exposing (closeButton)
import Tools


-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Model.OpenModel -> (Model.Workflow, Cmd Msg)
update msg open =
    case msg of
        SendHeartbeat _ ->
            ( Model.Open open, Common.sendHeartbeat open.context )

        HeartbeatResp (Err e) ->
            case e of
                Http.BadStatus _ ->
                    ( open.context.me
                        |> (\citizen -> Model.Guest citizen.id citizen.name)
                    , "You were kicked out by the server (probably a restart)"
                        |> Error.addError
                        |> Cmd.map ErrorMsg
                    )
                _ ->
                    ( Model.Open open
                    , Tools.httpErrorToString e
                        |> Error.addError
                        |> Cmd.map ErrorMsg
                    )

        Sync state ->
            ( { open | context = Model.sync state open.context }
                |> Model.Open
            , Cmd.none )

        CitizenLeft citizen ->
            if citizen == open.context.me then
                ( Model.Guest "" ""
                , Cmd.none )
            else
                ( { open | context = Model.removeCitizen open.context citizen }
                    |> Model.Open
                , Cmd.none )
        NewCitizen citizen ->
            ( { open | context = Model.enlist open.context citizen }
                |> Model.Open
            , Cmd.none )
        Vote newBallot ->
            ( { open | ballot = Just newBallot }
                |> Model.Open
            , vote newBallot)
        VoteAccepted newBallot ->
            ( { open | context =  Model.vote open.context newBallot }
                |> Model.Open
            , Cmd.none)
        Cancel citizen ->
            ( { open | ballot = Nothing }
                |> Model.Open
            , cancelVote citizen)
        VoteCancelled citizen ->
            ( { open | context =  Model.cancelVote open.context citizen, ballot = Nothing }
                |> Model.Open
            , Cmd.none)
        Close ->
            ( Model.Open open
            , close)
        PollClosed ->
            ( Model.Closed open.context
            , Cmd.none)
        _ ->
            ( Model.Open open
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
    case model.workflow of
        Model.Open open ->
            [ div [id "nation"]
                  (  votersHtml open.context.nation open.context.ballots
                  ++ [closeButton]
                  )
            , deckHtml open.context.deck open.context.me open.ballot]
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
