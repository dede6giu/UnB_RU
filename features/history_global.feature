Feature: Global access report
    As an admin
    I want to see every access entry and filter it by restaurant and turnstile

    Background:
        Given I am an admin
        And there are restaurants with turnstiles
        And I am on the "Histórico Global" page

    # Positive Scenarios
    Scenario: See every access ungrouped
        Given there is global history
        Then I should see newest access first

    Scenario: Filter the report by restaurant
        Given I know a restaurant
        And there is global history
        When I filter by the restaurant I know
        Then I should see only the entires of the restaurant I know

    Scenario: Filter the report by turnstile
        Given I know a restaurant
        And I know a turnstile of the restaurant I know
        And there is global history
        When I filter by the turnstile I know
        Then I should see only the entires of the turnstile I know

    # Negative Scenarios
    Scenario: No history yet
        # Given there is no global history
        Then I should see a no global history message