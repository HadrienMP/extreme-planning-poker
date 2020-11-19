module Model.Error exposing (..)

import Time exposing (Posix)

type alias Error =
    { content: String
    , time: Posix
    }
type alias Errors = List Error
