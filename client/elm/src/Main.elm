
module Main exposing (..)


import Html exposing (..)
-- import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (src, style, class, id, width, height, autoplay, loop) 
import Json.Decode as Json
import String
import String.Extra
import List.Extra
-- import Format
import Random
import Markdown
import Material
import Material.Textfield as Textfield
import Material.Options as Options exposing (css,on,input)
import Material.Options exposing (css)
import Material.Button as Button
import Material.Grid exposing (grid, cell, size, offset, Device(..))
import Animation
import Animation.Messenger exposing (State)
import Material.Scheme
import Json.Decode
import Http
import Model exposing (..)
import View exposing (view)
import Update exposing (update)



-- Helper functions


-- `goodQuestion` checks whether there are any common words between the
-- list of trigger words and the array of the model's `currentQuestion` string
-- goodQuestion: { a | currentQuestion : String, triggerWords : List String } -> Bool
{--
goodQuestion model =
  let

    -- Convert the `currentQuestion` string into an array of words
    currentQuestionArray =
      String.Extra.decapitalize model.currentQuestion
    --   |> Format.removePunctuation
      |> String.words

    -- `sharedElements` takes two arrays as arguments and returns a new array
    -- that contains the shared elements between them
    sharedElements : List a -> List a -> List a
    sharedElements first = 
      List.filter (\x -> List.member x first)
  in 
  List.length (sharedElements currentQuestionArray model.triggerWords) /= 0
--}

-- `isNotAQuestion` returns true if the player has not asked a question

-- Find out what the current type of answer the prime minister is responding with
{-- currentAnswerType model =
  if model.numberOfQuestionsAsked == 0 then
    None

  --else if isNotAQuestion model && not (goodQuestion model) then
  else if isNotAQuestion model && not (goodQuestion model) then
    QuestionNotClear

  -- The user hasn't finished asking questions and has asked no good questions
  else if model.numberOfQuestionsAsked < 5 && model.numberOfGoodQuestionsAsked == 0 then
    General

  -- The user hasn't finished asking questions, has asked one good question, and
  -- the current question is a good one
  else if model.numberOfQuestionsAsked < 5 && model.numberOfGoodQuestionsAsked == 1 && goodQuestion model then
    Annoyed

  -- The user hasn't finished asking questions, has asked 2 good questions, and the current question
  -- is a good one
  else if model.numberOfQuestionsAsked < 5 && model.numberOfGoodQuestionsAsked == 2 && goodQuestion model then
    Angry

  -- The user hasn't finished asking questions and has asked 3 good questions
  else if model.numberOfQuestionsAsked < 5 && model.numberOfGoodQuestionsAsked == 3 then
    FinishedAngry

  -- The user has finished asking questions but has asked no good questions
  else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 0 then
    FinishedPolite

  -- The user has finished asking questions and asked one good question
  else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 1 then
    FinishedPolite

  -- The user has finished asking questions asked 2 good questions, and the current question is
  -- a good one
  else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 2 && goodQuestion model then
    FinishedAngry

  -- The user has finished asking questions asked 2 good questions, and the current question is
  -- NOT a good one
  else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 2 && not (goodQuestion model) then
    FinishedPolite

  -- The user has finished asking questions and asked 3 good questions
  else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 3 then
    FinishedAngry

  else 
    General

--}


--view 



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch 
    [ Animation.subscription AnimateQuestion [ model.questionTextStyle ]
    , Animation.subscription AnimateAnswer [ model.answerTextStyle ]
    , Animation.subscription AnimateInstructionBox [ model.instructionBoxStyle ]
    , Animation.subscription AnimateGameOverBox [ model.gameOverBoxStyle ]
    ]


-- APP

main =
  Html.program
    { init = (init, Cmd.none) 
    , view = view
    , update = update
    , subscriptions = subscriptions
    }