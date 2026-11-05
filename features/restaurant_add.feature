Feature: Adding restaurants
    As an administrator
    I want to add restaurants
    So that employees can choose them in the control application and students may frequent them

    Background:
        Given I am logged in as an admin
        And I am on the "Cadastrar Restaurante" page

    # Positive Scenarios
    Scenario: Add a restaurant
        When I fill in "restaurant-name" correctly
        And I fill in "restaurant-campus" correctly
        And I click the create restaurant button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new restaurant

    # Negative Scenarios
    Scenario Outline: Add a restaurant with an invalid data
        When I fill in "<correct_id>" correctly
        And I fill in "<incorrect_id>" incorrectly
        And I click the create restaurant button
        Then I should be on the "Cadastrar Restaurante" page
        And I should see an <message> message

        Examples:
            | correct_id        | incorrect_id      | message                   |
            | restaurant-name   | restaurant-campus | invalid restaurant campus |
            | restaurant-campus | restaurant-name   | invalid restaurant name   |

    Scenario: Add an already existing restaurant
        Given there is a restaurant
        And I know a restaurant
        When I fill in "restaurant-name" knowingly
        And I fill in "restaurant-campus" knowingly
        And I click the create restaurant button
        Then I should be on the "Cadastrar Restaurante" page
        And I should see an already existing restaurant error message