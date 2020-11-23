module OtherHtml exposing (..)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, id, placeholder, value)
import Messages exposing (Msg(..))
import Html.Events exposing (..)

enlistForm : String -> Html Msg
enlistForm citizen =
    form [onSubmit Enlist, id "enlist-form"]
         [ input [placeholder "Who dat ?", onInput UpdateName, value citizen ] []
         , button [attribute "type" "submit"] [text "Register"]
         ]


closeButton : Html Msg
closeButton = button [onClick Close]
                     [ i [class "fas fa-unlock-alt"] []
                     , text " Close"
                     ]

startButton : Html Msg
startButton = button [onClick Start]
                     [ i [class "fas fa-sync-alt"] []
                     , text " Start"
                     ]