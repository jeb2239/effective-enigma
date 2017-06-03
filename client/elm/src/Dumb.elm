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
  { dieFace : Int
 
  }


init : (Model, Cmd Msg)
init =
  (Model 1 , Cmd.none)



-- UPDATE


type Msg
  = Roll
  | Check
  | Suggest (List String)
  | NewFace Int

port check : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model, Random.generate NewFace (Random.int 1 6))

    NewFace newFace ->
      (Model newFace, Cmd.none)

    Check ->
      ( model, check (toString model.dieFace) )

    Suggest newSuggestions ->
        
      ( Model model.dieFace , Cmd.none )



-- SUBSCRIPTIONS

port suggestions : (List String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  suggestions Suggest



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (toString model.dieFace) ]
    , button [ onClick Roll ] [ text "Roll" ]
    , button [ onClick Check] [text "Check" ]
    ]