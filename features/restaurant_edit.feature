Feature: Restaurant editing
    As an admin
    I want to edit a restaurant
    So that its information stays updated

    Background:
        Given I am logged in as an admin
        And there are restaurants
        And I know a restaurant
        And I am on knowing restaurant "Manejar Restaurante" page

    # Positive Scenarios
    Scenario Outline: Rename a restaurant or its campus
        Given I know all <i_know>
        When I fill in "<i_know_id>" unknowingly
        And I fill in "<knownt_id>" correctly
        And I click the save restaurant button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new "<i_know_id>"
        And operators should see the restaurant's new "<i_know_id>" on the "Configuração de Ponto" page

        Examples:
            | i_know            | i_know_id         | knownt_id         |
            | restaurant names  | restaurant-name   | restaurant-campus |
            | restaurant campus | restaurant-campus | restaurant-name   |

    # Negative Scenarios
    Scenario Outline: Invalid name
        When I fill in "<correct_id>" correctly
        And I fill in "<incorrect_id>" incorrectly
        And I click the save restaurant button
        Then I should be on the knowing "Manejar Restaurante" page
        And I should see an <message> message

        Examples:
            | correct_id        | incorrect_id      | message                   |
            | restaurant-name   | restaurant-campus | invalid restaurant campus |
            | restaurant-campus | restaurant-name   | invalid restaurant name   |

    Scenario: Renaming to an existing restaurant and campus
        Given I know another restaurant
        When I fill in "restaurant-name" with another
        And I fill in "restaurant-campus" with another
        And I click the save restaurant button
        Then I should be on the knowing "Manejar Restaurante" page
        And I should see an existing restaurant message