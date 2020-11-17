module Model.Deck exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)

type alias CardCode = String
type alias Card =
    { value : String
    , iconClass : String
    , code : CardCode
    }
type alias Deck = List Card

findBy : CardCode -> Deck -> Maybe Card
findBy code deck =
    List.filter (\card -> card.code == code) deck
    |> List.head

cardHtml : Card -> Html a
cardHtml card = cardHtml2 card []

cardHtml2 : Card -> List (Attribute a) -> Html a
cardHtml2 card additionalAttributes =
     button ( [class "card"] ++ additionalAttributes )
              [ i [ class card.iconClass ] []
              , p [] [text card.value]
              ]