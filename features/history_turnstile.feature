Feature: Local access history of the turnstile
    As an operator
    I want to see the accesses recorded at the turnstile I am operating
    So that I can audit the local flow

    Background:
        Given there are restaurants with turnstiles
        And I am an operator
        And I have a turnstile
        And I am on the "Histórico Local de Acessos" page

    # Positive Scenarios
    Scenario: See history of my turnstile
        Given my turnstile has history
        Then I should see the history of my turnstile
        And I should see newest access first

    Scenario: Blocked entries show the reason
        Given a student was blocked at my turnstile for some reason
        Then I should see a blocked turnstile entry
        And I should see that blocked entry reason

    # Negative Scenarios
    Scenario: Turnstile with no entries yet
        # Given my turnstile has no history
        Then I should see a no turnstile history message