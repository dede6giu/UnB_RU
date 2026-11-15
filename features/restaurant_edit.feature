Feature: Restaurant editing
    As an admin
    I want to edit a restaurant
    So that its information stays updated

    Background:
        Given I am an admin
        And there are restaurants
        And I know a restaurant
        And I am on a knowing restaurant edit page

    # Positive Scenarios
    Scenario Outline: Rename a restaurant or its campus
        When I fill in "<i_know_id>" avoiding all restaurants
        And I fill in "<knownt_id>" correctly
        And I click the save restaurant button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new "<i_know_id>"
        And operators should see the restaurant's new "<i_know_id>" on the "Configuração de Ponto" page

        Examples:
            | i_know_id         | knownt_id         |
            | restaurant_name   | restaurant_campus |
            | restaurant_campus | restaurant_name   |

    # Negative Scenarios
    Scenario Outline: Invalid name
        When I fill in "<correct_id>" correctly
        And I fill in "<incorrect_id>" incorrectly
        And I click the save restaurant button
        Then I should see an <message> message

        Examples:
            | correct_id        | incorrect_id      | message                    |
            | restaurant_name   | restaurant_campus | restaurant campus is empty |
            | restaurant_campus | restaurant_name   | restaurant name is empty   |

    Scenario: Renaming to an existing restaurant and campus
        Given I learn another restaurant
        When I fill in "restaurant_name" from another restaurant
        And I fill in "restaurant_campus" from another restaurant
        And I click the save restaurant button
        Then I should see an existing restaurant message