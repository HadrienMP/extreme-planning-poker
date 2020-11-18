port module Main exposing (..)

import Browser
import Html exposing (..)
import Json.Decode
import Messages exposing (Msg(..))
import Model.Ballots as Ballots exposing (Ballots)
import Model.Model as Model exposing (Context, Model(..))
import Model.Nation as Nation exposing (Citizen, Nation)
import OtherHtml exposing (enlistForm)
import Random
import Sse exposing (EventKind)
import Time
import Tools exposing (fold)
import Workflow.Closed as Closed
import Workflow.Guest as Guest
import Workflow.Open as Open

main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

-- PORTS
port messageReceiver : ((EventKind, Json.Decode.Value) -> msg) -> Sub msg

-- MODEL

init : () -> (Model, Cmd Msg)
init _ = (Guest "" "", Random.generate GeneratedId Tools.uuid)

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Error error -> Debug.log error (model, Cmd.none)
        _ ->
            case model of
                Guest _ _  -> Guest.update msg model
                Model.Open open -> Open.update msg open
                Closed _ -> Closed.update msg model

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch
    [ messageReceiver handleEvent, Time.every 1000 Tick ]

handleEvent : (EventKind, Json.Decode.Value) -> Msg
handleEvent event =
    event |> Sse.through dispatch |> fold Error identity

dispatch : Sse.Event -> Result String Msg
dispatch event =
    case event.kind of
        "enlisted" -> Sse.decodeData Nation.citizenDecoder event |> Result.map Enlisted
        "voteAccepted" -> Sse.decodeData Ballots.ballotDecoder event |> Result.map VoteAccepted
        "voteCancelled" -> Sse.decodeData Nation.citizenDecoder event |> Result.map VoteCancelled
        "pollClosed" -> Ok PollCLosed
        "pollStarted" -> Ok PollStarted
        "citizenLeft" -> Sse.decodeData Nation.citizenDecoder event |> Result.map CitizenLeft
        "sync" -> Sse.decodeData syncDecoder event |> Result.map Sync
        _ -> Err ("Unknown event type: " ++ event.kind)

syncDecoder : Json.Decode.Decoder (Nation, Ballots)
syncDecoder =
    Json.Decode.map2
        (\a b -> (a, b))
        (Json.Decode.field "nation" Nation.decoder)
        (Json.Decode.field "ballots" Ballots.decoder)

-- VIEW
view : Model -> Html Msg
view model =
    div []
        ( [h1 [] [text "Extreme Poker Planning"]]
        ++ case model of
            Guest _ guest -> [ enlistForm guest]
            Model.Open _ -> Open.view model
            Closed _ -> Closed.view model
        )

