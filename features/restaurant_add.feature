Feature: Adding restaurants
    As an administrator
    I want to add restaurants
    So that employees can choose them in the control application and students may frequent them

    Background:
        Given I am an admin
        And I am on the "Cadastrar Restaurante" page

    # Positive Scenarios
    Scenario: Add a restaurant
        When I fill in "restaurant_name" correctly
        And I fill in "restaurant_campus" correctly
        And I click the create restaurant button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new restaurant

    # Negative Scenarios
    Scenario Outline: Add a restaurant with invalid data
        When I fill in "<correct>" correctly
        And I fill in "<incorrect>" incorrectly
        And I click the create restaurant button
        Then I should be on the "Cadastrar Restaurante" page
        And I should see an <message> message

        Examples:
            | correct           | incorrect         | message                   |
            | restaurant_name   | restaurant_campus | invalid restaurant campus |
            | restaurant_campus | restaurant_name   | invalid restaurant name   |

    Scenario: Add an already existing restaurant
        Given there are restaurants
        And I know a restaurant
        When I fill in "restaurant_name" knowingly
        And I fill in "restaurant_campus" knowingly
        And I click the create restaurant button
        Then I should be on the "Cadastrar Restaurante" page
        And I should see an existing restaurant message