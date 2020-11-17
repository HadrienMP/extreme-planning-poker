module Sse exposing (Event, EventKind, through, decodeData)

import Json.Decode as J

type alias EventKind = String
type alias Event =
    { kind : EventKind
    , data : J.Value
    }

through : (Event -> Result String msg) -> (EventKind, J.Value) -> Result String msg
through dispatchF (kind, data) = dispatchF (Event kind data)

log : Result String Event -> Result String Event
log result = Result.map (\t -> Debug.log t.kind t) result

parse : J.Value -> Result String Event
parse json =
    parseString "type" json
    |> Result.map (\k -> Event k json)

parseString : String -> J.Value -> Result String String
parseString key event =
    J.decodeValue (J.field key J.string) event
    |> Result.mapError J.errorToString

decodeData : J.Decoder a -> Event -> Result String a
decodeData decoder event =
    J.decodeValue decoder event.data
    |> Result.mapError J.errorToString