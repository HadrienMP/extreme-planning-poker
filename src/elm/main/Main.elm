port module Main exposing (..)

import Browser
import Html exposing (..)
import Json.Decode
import Messages exposing (Msg(..), stateDecoder)
import Model.Ballots as Ballots exposing (Ballots)
import Error as Error
import Model.Model as Model exposing (Model, Poll(..), ConnectionState(..))
import Model.Nation as Nation exposing (Citizen, Nation)
import OtherHtml exposing (enlistForm)
import Random
import Sse exposing (EventKind)
import Tools exposing (fold)
import Workflow.Connected as Connected
import Workflow.Guest as Guest
import Workflow.Poll.Closed as Closed
import Workflow.Poll.Open as Open

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
init _ = (Guest "" "" |> Model Error.empty, Random.generate GeneratedId Tools.uuid)

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
            ( case model.connectionState of
                 Guest id name  -> Guest.update msg id name
                 Connected context other -> Connected.update msg context other
            )
            |> Tuple.mapFirst (Model model.errors)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ = messageReceiver handleEvent

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
        "citizenLeft" -> Sse.decodeData Json.Decode.string event |> Result.map CitizenLeft
        "sync" -> Sse.decodeData stateDecoder event |> Result.map Sync
        "sseClosed" -> Ok <| KickedOut "Closed server-sent events connection"
        _ -> Err ("Unknown event type: " ++ event.kind)

-- VIEW
view : Model -> Html Msg
view model =
    div []
        ( [ h1 [] [text "Extreme Poker Planning"]
          , Error.view model.errors |> Html.map ErrorMsg
          ]
          ++ case model.connectionState of
            Guest _ guest -> [ enlistForm guest]
            Model.Connected _ (Open _) -> Open.view model
            Model.Connected _ Closed -> Closed.view model
        )