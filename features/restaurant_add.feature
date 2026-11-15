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
        Then I should see an <message> message

        Examples:
            | correct           | incorrect         | message                    |
            | restaurant_name   | restaurant_campus | restaurant campus is empty |
            | restaurant_campus | restaurant_name   | restaurant name is empty   |

    Scenario: Add an already existing restaurant
        Given there are restaurants
        And I know a restaurant
        When I fill in "restaurant_name" from a known restaurant
        And I fill in "restaurant_campus" from a known restaurant
        And I click the create restaurant button
        Then I should see an existing restaurant message