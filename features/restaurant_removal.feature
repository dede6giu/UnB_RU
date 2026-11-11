Feature: Restaurant removal
    As an admin
    I want to remove a restaurant
    So that operators stop seeing restaurants that no longer exist

    Background:
        Given I am logged in as an admin
        And there is a restaurant with turnstiles
        And I know a restaurant
        And I am on the knowing "Manejar Restaurante" page

    # Positive scenarios
    Scenario: Remove a restaurant
        When I click the remove restaurant button
        And I confirm
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should not see the restaurant I know
        And I should not see the turnstiles from the restaurant I know

    # Negative scenarios
    Scenario: Give up mid-removal
        When I go to the "Manejar Restaurante" page
        And I click the remove restaurant button
        And I cancel
        Then I should be on the knowing "Manejar Restaurante" page
        And I should see the restaurant I know

    Scenario: Restaurant with a turnstile in operation
        Given the restaurant I know has a turnstile operating
        And I click the remove restaurant button
        And I confirm
        Then I should be on the knowing "Manejar Restaurante" page
        And I should see a turnstile in operation message