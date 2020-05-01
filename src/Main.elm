module Main exposing (..)

import Html exposing (..)
import Html exposing (text, h2, a, h3, h1, i, hr)
import Html.Attributes exposing (class, href, target)
import Html.Events exposing (..)


-- model


type alias Model =
    --{ selectedProject : Maybe String }
    { selectedProject : Maybe Project }


type alias Project =
    { name : String
    , text : String
    , url : String
    , img : String
    }


initialModel : Model
initialModel =
    { selectedProject = Nothing }



-- update


type Action
    = SelectProject Project



--update : Action -> Model -> Model


update : Action -> Model -> Model
update action model =
    case action of
        SelectProject proj ->
            { model
                | selectedProject =
                    case model.selectedProject of
                        Nothing ->
                            Just proj

                        Just p ->
                            if p.name == proj.name then
                                Nothing
                            else
                                Just proj
            }

spades : Project
spades =
    Project "Spades" "Anger your friends and defeat your opponents in this cooperative yet competitive card game." "http://spades.rawhat.net" ""


platformer : Project
platformer =
    Project "The Platformer" "This is a social gaming site." "http://platformer.rawhat.net" ""


chess : Project
chess =
    Project "EnjoyChess" "A multiplayer online chess game using WebSockets." "http://enjoychess.rawhat.net" ""


rating : Project
rating =
    Project "Oratio Webrating" "Provides a web interface for rating speeches based on various criteria." "http://github.com/rawhat/oratio-rating" ""


oratio : Project
oratio =
    Project "Oratio" "Upload powerpoint presentations and practice public speaking.  Receive feedback on pacing, volume, and other patterns, as well as a transcript." "http://tryoratio.com" ""



-- view
-- href "http://platformer.rawhat.net"
-- href "http://chess.rawhat.net"
-- href "http://github.com/rawhat/oratio-rating"
-- href "http://tryoratio.com"


displayProject : Maybe Project -> Html Action
displayProject proj =
    case proj of
        Nothing ->
            div [] [ text "Select a project to view more." ]

        Just p ->
            div []
                [ text p.text
                , div [ class "row" ]
                    [ i [ class "fa fa-link link-icon" ] []
                    , a [ href p.url, target "_blank" ] [ text p.url ]
                    ]
                ]


links : List ( Action, String )
links =
    [ ( SelectProject spades, "Spades" )
    , ( SelectProject platformer, "The Platformer" )
    , ( SelectProject chess, "EnjoyChess" )
    , ( SelectProject rating, "Oratio Webrating" )
    , ( SelectProject oratio, "Oratio" )
    ]


buildLinks : Model -> List (Html Action)
buildLinks model =
    List.map
        (\( ev, tx ) ->
            let
                classes =
                    "project-entry link"

                classNames =
                    case model.selectedProject of
                        Nothing ->
                            classes

                        Just p ->
                            if p.name == tx then
                                classes ++ " active"
                            else
                                classes
            in
                div [ class classNames, onClick ev ] [ text tx ]
        )
        links


view : Model -> Html Action
view model =
    div [ class "container-fluid" ]
        [ div [ class "main-div" ]
            [ div [ class "row" ] [ h1 [ class "main-header" ] [ text "r a w h a t" ] ]
            , div [ class "row" ]
                [ div [ class "row" ]
                    [ h2 [ class "projects-title" ] [ text "Projects" ]
                    ]
                , hr [] []
                , div [ class "row" ] (buildLinks model)
                , div [ class "row" ] [ displayProject model.selectedProject ]
                ]
            ]
        , div [ class "contact-area" ]
            [ div [ class "row" ] [ h4 [ class "name-text" ] [ text "alex manning" ] ]
            , a [ class "contact-link", href "mailto:alex.w.manning@gmail.com", target "_blank" ] [ i [ class "fa fa-2x fa-envelope-o" ] [] ]
            , a [ class "contact-link", href "http://github.com/rawhat", target "_blank" ] [ i [ class "fa fa-2x fa-github" ] [] ]
            , a [ class "contact-link", href "http://twitter.com/_alexmanning", target "_blank" ] [ i [ class "fa fa-2x fa-twitter" ] [] ]
            , a [ class "contact-link", href "https://www.linkedin.com/in/alexander-manning-3974538a", target "_blank" ] [ i [ class "fa fa-2x fa-linkedin" ] [] ]
            ]
        ]


main : Program Never Model Action
main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
