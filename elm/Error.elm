module Error exposing (..)

import Html exposing (Html, i, li, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Task
import Time exposing (Posix)

-- MODEL
type alias Error =
    { content: String
    , time: Posix
    }
type alias Errors = List Error

type Msg
    = Add String
    | Timed Error
    | Delete Error
    | Clean Posix

-- UPDATE

update : Msg -> Errors -> (Errors, Cmd Msg)
update msg errors =
    case msg of
        Add content -> ( errors, addError content )
        Timed error -> ( [error] ++ errors, Cmd.none )
        Delete error -> ( List.filter (\other -> other /= error) errors, Cmd.none )
        Clean now -> ( List.filter (isVisible now) errors, Cmd.none )

isVisible : Posix -> Error -> Bool
isVisible now error =
    (Time.posixToMillis now) - (Time.posixToMillis error.time) < 10000


addError : String -> Cmd Msg
addError error =
    Time.now
    |> Task.map (Error error)
    |> Task.perform Timed


-- VIEW

view : Errors -> Html Msg
view errors = ul [id "errors"] (List.map html errors)

html : Error -> Html Msg
html error =
    li [ onClick (Delete error) ]
       [ i [ class "fas fa-exclamation-circle"] []
       , text error.content
       , i [ class "fas fa-times close"] []
       ]