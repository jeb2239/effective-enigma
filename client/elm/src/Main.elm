
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
--import Data


-- DEFAULTS

type alias Defaults =
  { imagesLocation : String
  , titleFont : String
  , questionFont : String
  , fontFamily : String
  , hintFont : String
  }


defaults : Defaults
defaults =
  { imagesLocation = "images/"
  , titleFont = "Chunk, Georgia, serif"
  , questionFont = "LibreBaskerville-Regular, serif"
  , fontFamily = "Chronicle, 'Times New Roman', Georgia, serif"
  , hintFont = "Helvetica, Arial, sans"
  }


-- MODEL

type alias Model = 
  { content : String 
  , mdl : Material.Model
  , input : String
  , currentQuestion : String
  , currentAnswer : String
  , numberOfQuestionsAsked : Int
  , numberOfGoodQuestionsAsked : Int
  , inputEnabled : Bool
  , triggerWords : List String
  , questionWords : List String
  , questionsAsked : List String
  , answersGiven : List String
  , generalAnswers : List String
  , annoyedAnswers : List String
  , angryAnswers : List String
  , askButtonDisabled : Bool
  , finishedAngryAnswers : List String
  , finishedPoliteAnswers : List String
  , questionNotClearAnswers : List String
  , newAnswerGenerated : Bool
  , questionTextStyle : Animation.Messenger.State Msg
  , answerTextStyle : Animation.Messenger.State Msg
  , instructionBoxStyle : Animation.Messenger.State Msg
  , gameOverBoxStyle : Animation.Messenger.State Msg
  }


init : Model
init =
  { content = "test"
  , mdl = Material.model
  , input = ""
  , currentQuestion = ""
  , currentAnswer = ""
  , numberOfQuestionsAsked = 0
  , numberOfGoodQuestionsAsked = 0
  , inputEnabled = True
  , triggerWords = ["hello"] -- Data.triggerWords
  , questionWords = ["a question word"] -- Data.questionWords
  , questionsAsked = ["a new word"]
  , answersGiven = ["a cat in a hat"]
  , generalAnswers = ["cat hat"] --Data.generalAnswers
  , annoyedAnswers = ["hat feed"] --Data.annoyedAnswers
  , angryAnswers = [] --Data.angryAnswers
  , askButtonDisabled = False
  , finishedAngryAnswers =[]-- Data.finishedAngryAnswers
  , finishedPoliteAnswers = [] --Data.finishedPoliteAnswers
  , questionNotClearAnswers = [] --Data.questionNotClearAnswers
  , newAnswerGenerated = True
  , questionTextStyle = 
      Animation.style
        [ Animation.opacity 1.0
        ]
  , answerTextStyle = 
      Animation.style
        [ Animation.opacity 1.0
        ]
  , instructionBoxStyle = 
      Animation.style
        [ Animation.opacity 1.0
        ]
  , gameOverBoxStyle = 
      Animation.style
        [ Animation.opacity 0.0
        ]
  }




-- Answer types

type Answer 
  = General
  | Annoyed
  | Angry
  | FinishedAngry 
  | FinishedPolite
  | QuestionNotClear
  | None


-- UPDATE

type Msg
  = MDL (Material.Msg Msg)
  | AnimateQuestion Animation.Msg
  | AnimateAnswer Animation.Msg
  | AnimateInstructionBox Animation.Msg
  | AnimateGameOverBox Animation.Msg
  | AskQuestion 
  | ReadInput String
  | FadeInOutQuestion
  | FadeInOutAnswer
  | FadeInOutInstructionBox
  | FadeInOutGameOverBox
  | FadeOutGameOverBox
  | FadeInInstructionBox
  | EvaluateQuestion
  | GenerateAnswer
  | CheckForEndOfGame
  | PlayAgain
  | EndGame
  | GetAnswer Answer Int
  | UpdateAnswerArrays Answer Int
  | NoOp


-- Helper functions


-- `goodQuestion` checks whether there are any common words between the
-- list of trigger words and the array of the model's `currentQuestion` string
-- goodQuestion: { a | currentQuestion : String, triggerWords : List String } -> Bool

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


-- `isNotAQuestion` returns true if the player has not asked a question
isNotAQuestion model =
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
  List.length (sharedElements currentQuestionArray model.questionWords) == 0


-- Find out what the current type of answer the prime minister is responding with
currentAnswerType model =
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



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    AnimateQuestion animMsg ->
      let 
        (newStyle, cmds) = 
          Animation.Messenger.update
            animMsg
            model.questionTextStyle
      in
     ({ model
         | questionTextStyle = newStyle
     }
     , cmds 
     )

    AnimateAnswer animMsg ->
      let 
        (newStyle, cmds) = 
          Animation.Messenger.update
            animMsg
            model.answerTextStyle
      in
     ({ model
         | answerTextStyle = newStyle
     }
     , cmds 
     )

    AnimateInstructionBox animMsg ->
      let 
        (newStyle, cmds) = 
          Animation.Messenger.update
            animMsg
            model.instructionBoxStyle
      in
     ({ model
         | instructionBoxStyle = newStyle
     }
     , cmds 
     )

    AnimateGameOverBox animMsg ->
      let 
        (newStyle, cmds) = 
          Animation.Messenger.update
            animMsg
            model.gameOverBoxStyle
      in
     ({ model
         | gameOverBoxStyle = newStyle
     }
     , cmds 
     )
    
    ReadInput inputValue ->
      { model
          | input = inputValue
      } 
      ! []

    AskQuestion ->
      let 
        question =
          if model.input /= "" then
            model.input
          else
            model.currentQuestion

        resetInput =
          if model.input /= "" then
            ""
          else
            model.input
      in
      { model
          | currentQuestion = question
          , input = resetInput
          , questionsAsked = question :: model.questionsAsked
      } 
      ! [ ]

    -- Find out whether the user typed a "good question". That means they used
    -- some words in their question that directly matches words in
    -- in the `triggerWords` list  
    EvaluateQuestion ->
      let 


        -- Increase the "questions asked" counters based on what kind of question the user has asked
        newModel =
          if goodQuestion model then
            { model 
                | numberOfQuestionsAsked = model.numberOfQuestionsAsked + 1
                , numberOfGoodQuestionsAsked = model.numberOfGoodQuestionsAsked + 1
                , inputEnabled = True 
                , newAnswerGenerated = True
            }
          else
            { model 
                | numberOfQuestionsAsked = model.numberOfQuestionsAsked + 1
                , inputEnabled = True
                , newAnswerGenerated = True
            }

      in

      -- Return the model with the correct state, and return the correct command, 
      -- based on the kind of question the user has asked
      -- model0 ! [ cmd ]
      update GenerateAnswer newModel

    GenerateAnswer ->
      let

        -- Return the length of each list, based on the relevant Answer type 
        randomRange answerType =
          case answerType of
            General ->
              (List.length model.generalAnswers) - 1

            Annoyed ->
              (List.length model.annoyedAnswers) - 1

            Angry ->
              (List.length model.angryAnswers) - 1

            FinishedAngry ->
              (List.length model.finishedAngryAnswers) - 1

            FinishedPolite ->
              (List.length model.finishedPoliteAnswers) - 1

            QuestionNotClear ->
              (List.length model.questionNotClearAnswers) - 1
      
            None ->
              (List.length model.generalAnswers) - 1
        
        createCommandFrom : Answer -> Cmd Msg
        createCommandFrom answerType =
          Random.generate (GetAnswer answerType) (Random.int 0 (randomRange answerType))

      in
      -- Return the model with the correct state, and return the correct command, 
      -- based on the kind of question the user has asked
      model ! [ createCommandFrom (currentAnswerType model) ]


    GetAnswer answerType randomNumber ->
      let
        list = 
          case answerType of
            QuestionNotClear ->
              model.questionNotClearAnswers

            Angry ->
              model.angryAnswers

            General ->
              model.generalAnswers

            Annoyed ->
              model.annoyedAnswers

            FinishedAngry ->
              model.finishedAngryAnswers

            FinishedPolite ->
              model.finishedPoliteAnswers

            None ->
              model.generalAnswers

        answer = 
          List.Extra.getAt randomNumber list
          |> Maybe.withDefault "Can't find answer" 

        newModel =
          { model
              | currentAnswer = answer 
              , answersGiven = answer :: model.answersGiven
          }

      in  
      --update (UpdateAnswerArrays answerType randomNumber) newModel
      update (UpdateAnswerArrays (currentAnswerType newModel) randomNumber) newModel

    -- Remove the current answer from the relevant array to prevent it from being asked again
    UpdateAnswerArrays answerType index ->
      let
        newModel =
          case answerType of
            Angry ->
              { model | angryAnswers = List.Extra.removeAt index model.angryAnswers } 

            General ->
              { model | generalAnswers = List.Extra.removeAt index model.generalAnswers } 

            QuestionNotClear ->
              { model | questionNotClearAnswers = List.Extra.removeAt index model.questionNotClearAnswers } 

            Annoyed ->
              { model | annoyedAnswers = List.Extra.removeAt index model.annoyedAnswers } 

            FinishedAngry ->
              { model | finishedAngryAnswers = List.Extra.removeAt index model.finishedAngryAnswers } 

            FinishedPolite ->
              { model | finishedPoliteAnswers = List.Extra.removeAt index model.finishedPoliteAnswers } 

            None ->
              { model | generalAnswers = List.Extra.removeAt index model.generalAnswers } 

      in
      update CheckForEndOfGame newModel

    CheckForEndOfGame ->
      let
        msg = 
          if model.numberOfQuestionsAsked == 5 || model.numberOfGoodQuestionsAsked == 3 then
            FadeInOutInstructionBox
          else 
            NoOp
      in
      update msg model

    EndGame ->
      {-
      let
        _ = Debug.crash(toString model.numberOfQuestionsAsked)
      in
      -}
      { model
          | askButtonDisabled = True 
      }
      ! [ ]

    PlayAgain ->
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 1]
            ]
            model.instructionBoxStyle

        model0 =
          { init
              | instructionBoxStyle = newStyle
          }
      in
      model0 ! [ ]

    FadeInOutInstructionBox -> 
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 0]
            , Animation.Messenger.send EndGame
            , Animation.Messenger.send FadeInOutGameOverBox
            --, Animation.to [Animation.opacity 1]
            ]
            model.instructionBoxStyle
      in
      { model
          | instructionBoxStyle = newStyle
          , inputEnabled = False
          , newAnswerGenerated = False
      }
      ! [ ]

    FadeOutGameOverBox  ->
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 0]
            , Animation.Messenger.send PlayAgain
            --, Animation.Messenger.send FadeInInstructionBox
            ]
            model.gameOverBoxStyle
      in
      { model
          | gameOverBoxStyle = newStyle
      }
      ! [ ] 

    FadeInInstructionBox  ->
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 1]
            ]
            model.instructionBoxStyle
      in
      { model
          | instructionBoxStyle = newStyle
      }
      ! [ ] 

    FadeInOutGameOverBox -> 
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 1]
            --, Animation.Messenger.send EndGame
            --, Animation.to [Animation.opacity 1]
            ]
            model.gameOverBoxStyle
      in
      { model
          | gameOverBoxStyle = newStyle
          , newAnswerGenerated = True
      }
      ! [ ]

    FadeInOutQuestion -> 
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 0]
            , Animation.Messenger.send AskQuestion
            , Animation.to [Animation.opacity 1]
            , Animation.Messenger.send FadeInOutAnswer
            ]
            model.questionTextStyle
      in
      { model
          | questionTextStyle = newStyle
          , newAnswerGenerated = False
      }
      ! [ ]

    FadeInOutAnswer -> 
      let
        newStyle =
          Animation.interrupt
            [ Animation.to [Animation.opacity 0]
            , Animation.Messenger.send AskQuestion
            , Animation.Messenger.send EvaluateQuestion
            , Animation.to [Animation.opacity 1]
            ]
            model.answerTextStyle
      in
      { model
          | answerTextStyle = newStyle
      }
      ! [ ]

    MDL msg ->
      Material.update MDL msg model

    

    NoOp ->
      model ! []



-- VIEW

(=>) : a -> b -> ( a, b )
(=>) = (,)

view : Model -> Html Msg
view model =
  let
    titleStyle =
      style
      [ "font-size" => "2em"
      , "font-family" => defaults.titleFont
      --, "padding-top" => "1em"
      --, "padding-bottom" => "1em"
      , "margin-bottom" => "0em"
      , "padding-top" => "0em"
      , "margin-top" => "0em"
      ]

    mainContainerStyle =
      style
      [ "margin" => "0"
      --, "padding" => "2vh 5vw 2vh 5vw"
      --, "width" => "100vw"
      --, "height" => "100vh"
      , "width" => "888px"
      , "height" => "500px"
      --, "background-color" => "green"
      , "overflow" => "hidden"
      , "background-image" => ("url(" ++ defaults.imagesLocation ++ "mainContainerBackground.png" ++ ")")
      ]

    labelStyle =
      style
      [ "padding-bottom" => "0"
      , "margin-bottom" => "0"
      , "padding-top" => "1em"
      , "line-height" => "1.2em"
      ]

    instructionsStyle =
      style
      [ "line-height" => "1em"
      , "padding-top" => "0em"
      , "font-family" => defaults.fontFamily
      , "text-align" => "justify"
      , "font-size" => "0.95em"
      , "overflow-x" => "hidden"
      ] 

    labelHeadingStyle =
      style
      [ "font-weight" => "bold" 
      ] 

    exampleWordsStyle =
      style
      [ "display" => "inline-block"
      , "background-color" => "whiteSmoke"
      , "border-radius" => "3px"
      , "padding" => "0.1em 0.5em 0.1em 0.5em"
      ]

    buttonLabelStyle =
      style
      [ "float" => "left"
      , "font-weight" => "bold"
      ]

    buttonContainerStyle =
      style
      [ "display" => "block"
      , "width" => "100%"
      , "height" => "15%"
      -- , "background-color" => "red"
      ]

    gridStyle =
      style
      [ "object-fit" => "contain"
      ]

    instructionBoxStyle =
      style
      [ "position" => "absolute"
      , "width" => "100%"
      , "height" => "auto"
      , "overflow-y" => "hidden"
      ]

    questionStyle =
      let
        display =
          if model.currentQuestion == "" then
            "none"
          else
            "block"

      in
      style
      [ "font-family" => defaults.questionFont
      , "font-size" => "0.95em"
      , "line-height" => "1.1em"
      , "color" => "black"
      , "display" => display
      , "background-color" => "white"
      , "border-radius" => "10px"
      , "padding" => "0.5em 0.5em 0.5em 0.5em"
      , "-webkit-box-shadow" => "4px 4px 5px 0px rgba(50, 50, 50, 0.45)" 
      , "-moz-box-shadow" => "4px 4px 5px 0px rgba(50, 50, 50, 0.45)" 
      , "box-shadow" => "4px 4px 5px 0px rgba(50, 50, 50, 0.45)"
      , "width" => "250px"
      , "min-height" => "10px"
      , "position" => "absolute"
      , "left" => "78px"
      , "top" => "15px"
      ]

    answerStyle =
      let
        display =
          if model.currentAnswer == "" then
            "none"
          else
            "block"

      in
      style
      [ "font-family" => defaults.questionFont
      , "font-size" => "0.95em"
      , "line-height" => "1.1em"
      , "color" => "black"
      , "display" => display
      , "background-color" => "white"
      , "border-radius" => "10px"
      , "padding" => "0.5em 0.5em 0.5em 0.5em"
      , "-webkit-box-shadow" => "4px 4px 5px 0px rgba(50, 50, 50, 0.45)" 
      , "-moz-box-shadow" => "4px 4px 5px 0px rgba(50, 50, 50, 0.45)" 
      , "box-shadow" => "4px 4px 5px 0px rgba(50, 50, 50, 0.45)"
      , "width" => "330px"
      , "min-height" => "10px"
      , "position" => "absolute"
      , "left" => "39px"
      , "top" => "270px"
      ]

    imageStyle =
      style
      [ "display" => "block"
      , "margin" => "0 auto"
      ]

    publishedInterviewTextStyle = 
      style
      [ "fontFamily" => "'Times New Roman', Georgia, Serif"
      , "line-height" => "1em"
      , "line-height" => "1em"
      , "font-size" => "0.87em"
      , "padding-bottom" => "1em"
      , "margin" => "0"
      ]

    publishedInterviewPmTextStyle = 
      style
      [ "fontFamily" => "'Times New Roman', Georgia, Serif"
      , "line-height" => "1em"
      , "line-height" => "1em"
      , "font-size" => "0.87em"
      , "font-style" => "italic"
      , "padding-bottom" => "1em"
      , "margin" => "0"
      ]

    publishedInterviewContainerStyle = 
      style
      [ "fontFamily" => "'Times New Roman', Georgia, Serif"
      , "text-align" => "justify"
      , "width" => "91%"
      , "-webkit-column-count" => "2"
      , "-moz-column-count" => "2"
      , "column-count" => "2"
      , "-webkit-column-gap" => "20px"
      , "-moz-column-gap" => "20px"
      , "column-gap" => "20px"
      , "width" => "91%"
      , "margin-top" => "0.5em"
      ]

    newspaperClippingImageStyle = 
      style
      [ "padding-left" => "40px"
      , "display" => "block"
      ]

    primeMinisterImageStyle = 
      style
      [ "margin-left" => "10px"
      , "display" => "block"
      , "-webkit-box-shadow" => "2px 2px 3px 0px rgba(50, 50, 50, 0.45)" 
      , "-moz-box-shadow" => "2px 2px 3px 0px rgba(50, 50, 50, 0.45)" 
      , "box-shadow" => "2px 2px 3px 0px rgba(50, 50, 50, 0.45)"
      ]

    instructionsContainerStyle =
      style
      [ "-webkit-column-count" => "2"
      , "-moz-column-count" => "2"
      , "column-count" => "2"
      , "-webkit-column-gap" => "20px"
      , "-moz-column-gap" => "20px"
      , "column-gap" => "20px"
      , "width" => "91%"
      , "margin-top" => "0.5em"
      ]

    questionBoxContainerStyle =
      style
      [ "padding-left" => "10px"
      , "position" => "absolute"
      , "top" => "370px"
      , "left" =>"0px"
      ]

    questionMirrorContainerStyle =
      style
      [ "display" => "block"
      ]

    hintStyle =
      style
      [ "font-family" => defaults.hintFont
      , "font-weight" => "bold"
      , "padding-top" => "0"
      ]

    questionAndReplyContainer =
      style
      [ "position" => "absolute"
      , "top" => "0"
      , "left" => "0"
      ]

    emojiStyle =
      style
      [ "padding-right" => "10px"
      , "margin" => "0px"
      ]

    hintContainerStyle =
      style
      [ "display" => "flex"
      , "margin-top" => "-18px"
      ]

    mdlTextfield id msg =
      let
        tagger code =
            if code == 13 && model.inputEnabled && model.input /= "" then
                FadeInOutQuestion
            else
                NoOp
      in
      Textfield.render MDL [ id ] model.mdl
      [ Textfield.autofocus
      , Textfield.maxlength 230 
      , Textfield.textarea
      , Textfield.value model.input
      , Textfield.label "Type a question and press Ask..."
      , Textfield.rows 2
      --, Textfield.label "Enter words here..."
      , Options.on "input" (Json.map msg targetValue)
      , Options.on "keydown" (Json.map tagger keyCode)
      , Options.input 
        [ css "display" "block"
        , css "padding-bottom" "0"
        , css "margin-bottom" "0"
        --, css "padding-right" "20px"
        ]
      --, Textfield.value question.answer
      --, Textfield.on "input" (Json.map (UpdateField question) targetValue)

      -- Assign a unique html `id` attribute that matches the `question.id`. This is used 
      -- by the `SetFocus` message to set the input focus to the first question
      -- in the tab list when a tab is clicked or the `next paragraph` button is clicked
      --, Textfield.style [ Options.attribute <| Html.Attributes.id ("question" ++ toString (question.id)) ]
      --, css "width" "90%"
      --, Textfield.text' question.answer
      ]

    horizontalRuleStyle =
      style
      [ "border-color" => "black"
      , "width" => "91%"
      ]

    generateButton id labelContent msg =
      let 
        message =
          if model.inputEnabled && model.input /= "" then
            msg
          else
            NoOp

        buttonProperties =
          if model.askButtonDisabled then
            [ Button.ripple
            , Button.raised
            , Button.colored
            -- , Options.onClick FadeInOut -- SendStoryComponents 
            , Options.onClick message -- AskQuestion
            , Button.disabled 
            , css "margin-top" "0.5em"
            , css "display" "inline"
            , css "float" "right"
            , css "margin-left" "30px"
            , css "margin-top" "20px"
            {-
            , css "padding-top" "0px"
            , css "padding-left" "10px"
           -}
            --, css "margin-bottom" "2em"
            ]
            --[ text labelContent ]

          else
            [ Button.ripple
            , Button.raised
            , Button.colored
            --, Button.onClick FadeInOut -- SendStoryComponents 
            , Options.onClick message -- AskQuestion
            --, css "margin-top" "0.5em"
            , css "display" "inline"
            , css "float" "right"
            , css "margin-left" "30px"
            , css "margin-top" "20px"
            {-
            , css "padding-top" "0px"
            , css "padding-left" "10px"
           -}
            --, css "margin-bottom" "2em"
            ]
            --[ text labelContent ]
      in
      Button.render MDL [ id ] model.mdl buttonProperties [ text labelContent ]

    generateTryAgainButton id labelContent msg =
      Button.render MDL [ id ] model.mdl
       [ Button.ripple
       , Button.raised
       , Button.colored
       --, Button.onClick FadeInOut -- SendStoryComponents 
       , Options.onClick msg -- AskQuestion
       --, css "margin-top" "0.5em"
       , css "display" "block"
       , css "margin-top" "1em"
       , css "margin-bottom" "1em"
       ]
       [ text labelContent ]

    -- FORMATTING
    -- The specific way in which this essay should be formatted

    format : String -> String
    format question = question
  --    Format.trimExtraWhitespace question
 --     |> Format.addFinalQuestionMark
 --     |> Format.removeSpaceBeforePeriod
  --    |> Format.capitalizeFirstCharacter
  --    |> Format.addQuotes
      --|> (Format.formatAuthorOfQuotation question.format)
      --|> Format.addSpaceBetweenSentences

    -- addQuotes : String -> String
    -- addQuotes =
    --   Format.addQuotes

    gameOverText =

      -- The user finished asking 5 questions, but didn't ask any good questions
      if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 0 then
        "Data.result0" 

      -- The user finished asking questions, and asked 1 good question
      else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 1 then
        "Data.result1"

      -- The user finished asking questions, and asked 2 good questions
      else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 2 then
        "Data.result4"

      -- The user finished asking questions, and asked 3 good questions
      else if model.numberOfQuestionsAsked == 5 && model.numberOfGoodQuestionsAsked == 3 then
        "Data.result2"

      -- The user asked less than 5 questions and asked 3 good questions
      else if model.numberOfQuestionsAsked < 5 && model.numberOfGoodQuestionsAsked == 3 then
        "Data.result3"
 
      -- The default: this should never appear, so if it does you there's something wrong
      -- with the way the questions are being counted
      else
        "Game Over!"

    getHint =
      if model.newAnswerGenerated then
        case currentAnswerType model of
          General ->
            "He's trying to change the topic! Try asking directly about the corruption allegations."
    
          Annoyed ->
            "Good question! It annoyed him but you're on the right track!"

          Angry ->
            "That made him angry, but it's an excellent question!"

          FinishedAngry ->
            "That question made him really mad, but he let some information slip that's great for your interview." 

          FinishedPolite ->
            "At least you ended the interview a friendly way."

          QuestionNotClear ->
            "He didn't understand that. Try starting your question with Who, What, Where, How or When."

          None ->
            "Try asking a question starting with Who, What, Where, How or When."
      else 
        ""

    emojiType =
      if model.newAnswerGenerated then
         case currentAnswerType model of
          General ->
            "veryConcerned.svg"
    
          Annoyed ->
            "happy.svg"

          Angry ->
            "veryHappy.svg"

          FinishedAngry ->
            "interviewSucceeded.svg" 

          FinishedPolite ->
            "uncertain.svg"

          QuestionNotClear ->
            "doesntUnderstand.svg"

          None ->
            "neutral.svg"
      else
        "neutral.svg"



    questionList index question = 
      div [ ] 
        [ p [ publishedInterviewTextStyle ] [ text <| "Reporter: " ++ question ]
        , p [ publishedInterviewPmTextStyle ] [ text <| "P.M: " ++ (List.Extra.getAt index (List.reverse model.answersGiven) |> Maybe.withDefault "") ]
        ]

    printInterview =
      if model.numberOfGoodQuestionsAsked == 3 then
        div [ publishedInterviewContainerStyle ] (List.indexedMap questionList (List.reverse model.questionsAsked))
      else
        div [ ] [ ]

  in

  div [ mainContainerStyle ]
    [ grid [ css "object-fit" "contain" ]

      -- The left-hand cell that contains the instructions and the game over text
      [ cell 
        [ size Tablet 6
        , size Desktop 6
        , size Phone 12
        , css "position" "relative"
        , css "padding" "2%", css "height" "468px"
        , css "background-image" ("url(" ++ defaults.imagesLocation ++ "newsprintTexture.png" ++ ")")
        , css "-webkit-box-shadow" "4px 4px 5px 0px rgba(50, 50, 50, 0.45)" 
        , css "-moz-box-shadow" "4px 4px 5px 0px rgba(50, 50, 50, 0.45)" 
        , css "box-shadow" "4px 4px 5px 0px rgba(50, 50, 50, 0.45)"
        , css "overflow-y" "scroll" 
        , css "overflow-x" "hidden" 
        ]

        -- The instruction text and newspaper clipping
        [ div (Animation.render model.instructionBoxStyle ++ [ instructionBoxStyle ]) 
          [ h1 [ titleStyle ] [ text "Interview the Prime Minister" ]
          , img [ src (defaults.imagesLocation ++ "newspaperClippingMedium.png"), newspaperClippingImageStyle ] [ ]
          , div [ instructionsContainerStyle ] 
            [ Markdown.toHtml [ instructionsStyle ]  "hey"
            ]
          ]

        -- The game over text, Try Again button and published interview. The published interview is only displayed if
        -- The player manages to ask at least 2 provocative questions and gets through 5 questions in total
        , div (Animation.render model.gameOverBoxStyle ++ [ instructionBoxStyle ])
          [ Markdown.toHtml [ id "gameOver" ] gameOverText
          , hr [ horizontalRuleStyle ] [ ]
          , printInterview -- div [ publishedInterviewContainerStyle ] (List.indexedMap questionList (List.reverse model.questionsAsked))
          , generateTryAgainButton 2 "Try Again" FadeOutGameOverBox
          ]
        ]

      -- The right-hand cell that contains the Prime Minister, input textfield, input button
      -- and the asked questions and replies
      , cell [ size Tablet 6, size Desktop 6, size Phone 12, css "position" "relative" ]
        --[ img [ src (defaults.imagesLocation ++ "primeMinisterInFrame.png"), primeMinisterImageStyle ] [ ]
        [ video [ width 400, height 300, autoplay True, loop True ]  [  source [ src "video/general.mp4" ] [ ] ] 
        , div [ questionBoxContainerStyle ] 
          [ mdlTextfield 0 ReadInput 0
          , generateButton 1 "Ask!" FadeInOutQuestion
          , div [ hintContainerStyle ]
            [ img [ src (defaults.imagesLocation ++ emojiType), width 32, height 32, emojiStyle ] []
            , p [ hintStyle ] [ text getHint ]
            ]
          ]

        -- A container for the asked questions and the replies. The question and reply elements
        -- are absolutely positioned
        , div [ questionAndReplyContainer ] 
          --[ p (Animation.render model.questionTextStyle ++ [ questionStyle ]) [ text <| format model.currentQuestion ]
          [ p (Animation.render model.answerTextStyle ++ [ answerStyle ]) [ text {--<| addQuotes--} model.currentAnswer ]
          ]
        -- Diagnostic
        {-
        , p [ ] [ text <| "Good Questions: " ++ (toString model.numberOfGoodQuestionsAsked) ]
        , p [ ] [ text <| "Boring Questions: " ++  (toString <| model.numberOfQuestionsAsked - model.numberOfGoodQuestionsAsked) ]
        , p [ ] [ text <| "Total Questions: " ++  (toString model.numberOfQuestionsAsked) ]
        -}
        ]
      ]
    ] |> Material.Scheme.top




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