Feature: Basic Access Control
    As the application
    I want to check if a student has enough balance before allowing them in, and then debting them

    Background:
        Given I am the application
        And there is students with enough balance
        And there is students without enough balance

    # Positive Scenarios
    Scenario: Debit Student with Balance
        When I check a student with enough balance
        Then I should send an allow student message
        And I the student balance should be a meal lower

    # Negative Scenarios
    Scenario: Block Student without Balance
        When I check a student without enough balance
        Then I should send an block student message

    Scenario: Block unregistered students
        When I check an unregistered student
        Then I should send an unregistered student message