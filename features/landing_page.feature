Feature: Landing page
    As someone visiting the site
    I want a home page with the menu of the next meal and a way in for each profile
    So that I can check the food and get to the right login

    Background:
        Given I am on the "Página Inicial" page

    # Positive Scenarios
    Scenario: See the menu of the next meal
        Given it is Monday during lunch time
        Then I should see the lunch menu for Monday

    Scenario: Go to the full menu
        When I click on the full menu button
        Then I should be on the "Cardápio" page

    Scenario Outline: Go to the login of each profile
        When I click on the <profile> button
        Then I should be on the "<page>" page

        Examples:
            | profile        | page                      |
            | student login  | Autenticação do Estudante |
            | student signup | Cadastro Estudantil       |
            | operator login | Autenticação do Operador  |
            | admin login    | Autenticação de Admin     |

    # Negative Scenarios
    Scenario: Student already logged in goes straight to the portal
        Given I am a student
        When I go to the "Página Inicial" page
        Then I should be on the "Portal do Estudante" page
