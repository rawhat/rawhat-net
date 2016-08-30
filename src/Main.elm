module Main exposing (..)

import Html exposing (..)
import Html exposing (text, h2, a, h3, h1, i, hr)
import Html.Attributes exposing (class, href, target)


main : Html a
main =
    div [ class "container-fluid" ]
        [ div [ class "main-div" ]
            [ div [ class "row" ] [ h1 [ class "main-header" ] [ text "r a w h a t" ] ]
            , div [ class "row" ]
                [ div [ class "row" ]
                    [ h2 [ class "projects-title" ] [ text "Projects" ]
                    ]
                , hr [] []
                , div [ class "row" ]
                    [ a [ class "project-entry link", href "http://platformer.rawhat.net" ] [ text "The Platformer" ]
                    ]
                , div [ class "row" ]
                    [ a [ class "project-entry link", href "http://chess.rawhat.net" ] [ text "EnjoyChess" ]
                    ]
                , div [ class "row" ]
                    [ a [ class "project-entry link", href "http://github.com/rawhat/oratio-rating" ] [ text "Oratio Webrating" ]
                    ]
                , div [ class "row" ]
                    [ a [ class "project-entry link", href "http://tryoratio.com" ] [ text "Oratio" ]
                    ]
                ]
            ]
        , div [ class "contact-area" ]
            [ a [ class "contact-link", href "mailto:alex.w.manning@gmail.com", target "_blank" ] [ i [ class "fa fa-2x fa-envelope-o" ] [] ]
            , a [ class "contact-link", href "http://github.com/rawhat", target "_blank" ] [ i [ class "fa fa-2x fa-github" ] [] ]
            , a [ class "contact-link", href "http://twitter.com/_alexmanning", target "_blank" ] [ i [ class "fa fa-2x fa-twitter" ] [] ]
            , a [ class "contact-link", href "https://www.linkedin.com/in/alexander-manning-3974538a", target "_blank" ] [ i [ class "fa fa-2x fa-linkedin" ] [] ]
            ]
        ]
