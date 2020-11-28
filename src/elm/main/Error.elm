module Error exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, i, li, span, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Task
import Time exposing (Posix)

-- MODEL
type alias Error =
    { content: String
    , time: Posix
    }
type alias Errors = Dict String (Int, Error)

type Msg
    = Add String
    | Timed Error
    | Delete Error

empty = Dict.empty

-- UPDATE

update : Msg -> Errors -> (Errors, Cmd Msg)
update msg errors =
    case msg of
        Add content -> ( errors, timeError content )
        Timed error -> ( addError error errors, Cmd.none )
        Delete error -> ( Dict.filter (\other _ -> other /= error.content) errors, Cmd.none )

addError : Error -> Errors -> Errors
addError error errors =
    Dict.update
        error.content
        (\x ->
            case x of
                Just (count, _) -> Just (count + 1, error)
                Nothing -> Just (1, error)
        )
        errors

isVisible : Posix -> String -> (Int, Error) -> Bool
isVisible now _ (_, error) =
    (Time.posixToMillis now) - (Time.posixToMillis error.time) < 10000


timeError : String -> Cmd Msg
timeError error =
    Time.now
    |> Task.map (Error error)
    |> Task.perform Timed


-- VIEW

view : Errors -> Html Msg
view errors = ul [id "errors"] <| List.map html <| Dict.values errors

html : (Int, Error) -> Html Msg
html (count, error) =
    li [ onClick (Delete error) ]
       [ i [ class "fas fa-exclamation-circle"] []
       , text error.content
       , i [ class "fas fa-times close"] []
       , countHtml count
       ]

countHtml : Int -> Html Msg
countHtml count =
    if count >= 10 then [text "…"] |> span [class "count"]
    else if count == 1 then span [] []
    else [text <| String.fromInt count] |> span [class "count"]