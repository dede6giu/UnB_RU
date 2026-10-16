Feature: Time frame removal
    As an administrator
    I want to remove FastPass time frames
    So that students only enroll in time frames that really exist

    Background:
        Given I am logged in as an admin
        And the lunch shift goes from "11:15" to "14:15"
        And the lunch shift has a time frame from "12:00" to "12:15"
        And I am on the "Turnos e Time-frames" page

    # Positive Scenarios
    Scenario: Remove a time frame
        When I click the remove button of the "12:00" to "12:15" time frame
        And I confirm the removal
        Then I should not see the "12:00" to "12:15" time frame in the lunch shift

    # Negative Scenarios
    Scenario: Give up mid-removal
        When I click the remove button of the "12:00" to "12:15" time frame
        And I cancel the removal
        Then I should see the "12:00" to "12:15" time frame in the lunch shift

    Scenario: Time frame with students enrolled
        Given there are students enrolled in the "12:00" to "12:15" time frame
        When I click the remove button of the "12:00" to "12:15" time frame
        And I confirm the removal
        Then I should see the "12:00" to "12:15" time frame in the lunch shift
        And I should see a time frame with students enrolled message
