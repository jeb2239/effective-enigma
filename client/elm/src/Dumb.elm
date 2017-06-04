port module Dumb exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Random



main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { dieFace : Int,
    listo : List String
  }


init : (Model, Cmd Msg)
init =
  ((Model 1 ["hello"]), Cmd.none)



-- UPDATE


type Msg
  = Roll
  | Check
  | Watson (List String)
  | NewFace Int

port check : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model, Random.generate NewFace (Random.int 1 6))
    NewFace newFace ->
      (Model newFace model.listo, Cmd.none)
    Check ->
      ( model, check ((toString model.dieFace) ++ (toString model.listo)) )
    Watson newSuggestions ->
      ( Model model.dieFace newSuggestions , Cmd.none )



-- SUBSCRIPTIONS

port suggestions : (List String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  suggestions Watson



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (toString model.dieFace) ]
    , h1 [] [ text (toString model.listo )]
    , button [ onClick Roll ] [ text "Roll" ]
    , button [ onClick Check] [text "Check" ]
    ]