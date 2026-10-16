Feature: Local access history of the turnstile
    As an operator
    I want to see the accesses recorded at the turnstile I am operating
    So that I can audit the local flow

    Background:
        Given there are restaurants with turnstiles
        And I am an assigned operator
        And I am on the "Histórico Local de Acessos" page

    # Positive Scenarios
    Scenario: See history of my turnstile
        Given my turnstile has history
        Then I should see the history of my turnstile
        And the most recent entry should appear first

    # Negative Scenarios
    Scenario: Turnstile with no entries yet
        # Given my turnstile has no history
        Then I should see a no turnstile history message

    Scenario: Blocked entries show the reason
        Given a student was blocked at my turnstile for not having enough balance
        Then I should see a blocked turnstile entry
        And I should see a not enough balance turnstile entry reason