Feature: Shift editing
    As an administrator
    I want to define the start and end time of each meal shift
    So that the turnstiles and the FastPass follow the restaurant schedule

    Background:
        Given I am logged in as an admin
        And I am on the "Turnos e Time-frames" page
        And the breakfast shift goes from "07:00" to "09:00"
        And the lunch shift goes from "11:15" to "14:15"

    # Positive Scenarios
    Scenario: Change the lunch shift
        When I set the lunch shift from "11:00" to "14:30"
        And I click on the save configuration button
        Then I should see the lunch shift going from "11:00" to "14:30"

    # Negative Scenarios
    Scenario Outline: Invalid lunch shift
        When I set the lunch shift from "<start>" to "<end>"
        And I click on the save configuration button
        Then I should see an invalid shift message

        Examples:
            | start | end   | reason                   |
            | 14:15 | 11:15 | ends before it starts    |
            | 08:30 | 14:15 | overlaps breakfast       |
            | 25:00 | 14:15 | time that does not exist |
