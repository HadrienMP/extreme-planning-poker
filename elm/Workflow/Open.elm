module Workflow.Open exposing (..)

import Http
import Model.Ballots as Ballots exposing (Ballot, hasVoted, Ballots)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model.Model as Model exposing (Context, Model(..), OpenModel)
import Model.Nation as Nation exposing (..)
import Model.Deck exposing (Card, Deck, cardHtml2)
import Messages exposing (Msg(..))
import Model.Model exposing (Context, Model(..))
import Html exposing (..)
import Html.Attributes exposing (class, classList, id)
import Model.Nation exposing (Citizen, Nation)
import OtherHtml exposing (closeButton, enlistForm)


-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case model of
        Model.Open open ->
            case msg of
                UpdateName _ ->
                    ( Debug.todo "Allow users to change their name"
                    , Cmd.none )
                Enlisted citizen ->
                    ( Model.Open { open | context = Model.enlist open.context citizen }
                    , Cmd.none )
                NationUpdated nationResponse ->
                    case nationResponse of
                        Err _ ->
                            ( Debug.todo "Handle nation updated error cases"
                            , Cmd.none )
                        Ok nation ->
                            ( Model.Open { open | context = Model.updateNation open.context nation }
                            , Cmd.none )
                Vote newBallot ->
                    ( Model.Open { open | ballot = Just newBallot }
                    , vote newBallot)
                VoteAccepted newBallot ->
                    ( Model.Open { open | context =  Model.vote open.context newBallot }
                    , Cmd.none)
                Cancel citizen ->
                    ( Model.Open { open | ballot = Nothing }
                    , cancelVote citizen)
                VoteCancelled citizen ->
                    ( Model.Open { open | context =  Model.cancelVote open.context citizen, ballot = Nothing }
                    , Cmd.none)
                Close -> (model, close)
                PollCLosed -> ( Model.Closed open.context, Cmd.none)
                _ -> (model, Cmd.none)
        _ -> (model, Cmd.none)


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
    case model of
        Model.Open open ->
            [ enlistForm open.context.updatedName
            , div [id "nation"]
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
