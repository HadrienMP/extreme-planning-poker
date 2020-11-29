module Workflow.Closed exposing (..)
import Common exposing (kickedOut)
import Http
import Model.Ballots as Ballots exposing (Ballots)
import Model.Deck as Deck exposing (Card, Deck)
import Messages exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (id)
import Error as Error
import Model.Model as Model exposing (Model, Workflow(..))
import Model.Nation as Nation exposing (Citizen, Nation, citizenHtml)
import OtherHtml exposing (startButton)
import Tools

-- ###################################################
-- UPDATE
-- ###################################################

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case model.workflow of
        Closed context ->
            case msg of
                KickedOut reason -> context.me |> kickedOut reason |> Tuple.mapFirst (Model model.errors)
                Sync sync ->
                    ( { model | workflow = (Closed (Model.sync sync context)) }
                    , Error.timeError "Out of sync" |> Cmd.map ErrorMsg
                    )
                CitizenLeft citizen ->
                    if citizen == context.me.id then
                        ( { model | workflow = Guest "" "" }
                        , Cmd.none )
                    else
                        ( Model.removeCitizen context citizen
                            |> Closed
                            |> Model model.errors
                        , Cmd.none )
                Start -> (model, start)
                PollStarted ->
                    ( Model.OpenModel (Model.reset context) Nothing
                        |> Open
                        |> Model model.errors
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