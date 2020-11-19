port module Main exposing (..)

import Browser
import Common
import Html exposing (..)
import Json.Decode
import Messages exposing (Msg(..))
import Model.Ballots as Ballots exposing (Ballots)
import Model.Error as Error exposing (Error)
import Model.Model as Model exposing (Model, Workflow(..))
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
init _ = (Guest "" "" |> Model [], Random.generate GeneratedId Tools.uuid)

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ErrorMsg errorMsg ->
            Error.update errorMsg model.errors
            |> Tuple.mapBoth
                (\updated -> { model | errors = updated } )
                (Cmd.map ErrorMsg)
        _ ->
            case model.workflow of
                Guest _ _  -> Guest.update msg model
                Model.Open open -> Open.update msg open |> Tuple.mapFirst (Model model.errors)
                Closed _ -> Closed.update msg model


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch
    [ messageReceiver handleEvent
    , Time.every 1000 SendHeartbeat
    , Time.every 1000 (\now -> Error.Clean now |> ErrorMsg)
    ]

handleEvent : (EventKind, Json.Decode.Value) -> Msg
handleEvent event =
    Sse.through dispatch event
    |> fold (\error -> Error.Add error |> ErrorMsg) identity

dispatch : Sse.Event -> Result String Msg
dispatch event =
    case event.kind of
        "enlisted" -> Sse.decodeData Nation.citizenDecoder event |> Result.map NewCitizen
        "voteAccepted" -> Sse.decodeData Ballots.ballotDecoder event |> Result.map VoteAccepted
        "voteCancelled" -> Sse.decodeData Nation.citizenDecoder event |> Result.map VoteCancelled
        "pollClosed" -> Ok PollClosed
        "pollStarted" -> Ok PollStarted
        "citizenLeft" -> Sse.decodeData Nation.citizenDecoder event |> Result.map CitizenLeft
        "sync" -> Sse.decodeData Common.stateDecoder event |> Result.map Sync
        _ -> Err ("Unknown event type: " ++ event.kind)

-- VIEW
view : Model -> Html Msg
view model =
    div []
        ( [ h1 [] [text "Extreme Poker Planning"]
          , Error.view model.errors |> Html.map ErrorMsg
          ]
          ++ case model.workflow of
            Guest _ guest -> [ enlistForm guest]
            Model.Open _ -> Open.view model
            Closed _ -> Closed.view model
        )