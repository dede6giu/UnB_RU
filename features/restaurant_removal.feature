Feature: Restaurant removal
    As an admin
    I want to remove a restaurant
    So that operators stop seeing restaurants that no longer exist

    Background:
        Given I am an admin
        And there is a restaurant
        And there exists turnstiles that are non-operational
        And I know a restaurant
        And I am on a knowing restaurant edit page

    # Positive scenarios
    @javascript
    Scenario: Remove a restaurant
        Given the restaurant I know has a non-operational turnstile
        When I click the remove restaurant link, and confirm
        Then I should not see the restaurant I know
#        And I should not see the turnstiles from the restaurant I know

    # Negative scenarios
    @javascript
    Scenario: Give up mid-removal
        When I click the remove restaurant link, and cancel
        And I go to the "Gestão de Restaurantes e Catracas" page
        Then I should see the restaurant I know

    @javascript
    Scenario: Restaurant with a turnstile in operation
        Given the restaurant I know has a operational turnstile
        And I click the remove restaurant link, and confirm
        Then I should see a turnstile in operation message
        And I should see the restaurant I know