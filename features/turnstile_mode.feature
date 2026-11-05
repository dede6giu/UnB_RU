Feature: Turnstile mode
    As an operator
    I want to switch my turnstile between common mode and FastPass exclusive mode
    So that the express corridor only lets FastPass students in when needed

    Background:
        Given there are restaurants with turnstiles
        And I am an assigned operator
        And I am on the "Terminal de Validação" page

    # Positive Scenarios
    Scenario: Switch to FastPass exclusive mode
        Given the current meal has FastPass time frames
        When I click the FastPass exclusive mode button
        Then I should see my turnstile in FastPass exclusive mode

    Scenario: Switch back to common mode
        Given my turnstile is in FastPass exclusive mode
        When I click the common mode button
        Then I should see my turnstile in common mode

    # Negative Scenarios
    Scenario: FastPass exclusive mode in a meal without FastPass
        Given the current meal has no FastPass time frames
        When I click the FastPass exclusive mode button
        Then I should see a no FastPass for this meal message
        And I should see my turnstile in common mode
