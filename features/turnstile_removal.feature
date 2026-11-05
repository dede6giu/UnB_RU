Feature: Turnstile removal
    As an admin
    I want to remove a turnstile
    So that operators only see turnstiles that really exist

    Background:
        Given I am an admin
        And there are restaurants with turnstiles
        And I know a restaurant
        And I know a turnstile from the restaurant I know
        And I am on the knowing "Manejar Catraca" page

    # Positive scenarios
    Scenario: Remove a turnstile
        When I click the remove turnstile button
        And I confirm
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should not see the turnstile I know

    # Negative scenarios
    Scenario: Give up mid-removal
        When I click the remove turnstile button
        And I cancel
        Then I should be on the knowing "Manejar Catraca" page
        And I should see the turnstile I know

    Scenario: Turnstile in operation
        Given the turnstile I know is operating
        When I click the remove turnstile button
        And I confirm
        Then I should be on the knowing "Manejar Catraca" page
        And I should see a turnstile in operation message