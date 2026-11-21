Feature: Validation terminal
    As an operator
    I want to type the student's registration on the validation terminal
    So that the student only gets in with enough balance

    Background:
        Given I am an operator
        And I have a turnstile
        And I am on the "Terminal de Validação" page

    # Positive Scenarios
    Scenario: Student with enough balance
        Given there are students with enough balance
        When I validate the registration of a student with enough balance
        Then I should see an access allowed message
        And the student's balance should be a meal lower

    # Negative Scenarios
    Scenario: Student without enough balance
        Given there are students without enough balance
        When I validate the registration of a student without enough balance
        Then I should see a not enough balance message
        And the student's balance should be unchanged

    Scenario: Unregistered registration
        When I validate an unregistered registration
        Then I should see an unregistered registration message
