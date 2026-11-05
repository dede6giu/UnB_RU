Feature: Shift and Time-frame Management
    As an administrator
    I want to create as many FastPass time frames as I want,
    for any meal and with any duration
    So that I can organize the distribution of FastPasses

    Background:
        Given I am logged in as an admin
        And I am on the "Turnos e Time-frames" page
        And the lunch shift goes from "11:15" to "14:15"

    # Positive Scenarios
    Scenario Outline: Create a FastPass time frame
        When I create a lunch time frame from "<start>" to "<end>"
        And I click on the save configuration button
        Then I should see the "<start>" to "<end>" time frame in the lunch shift

        Examples:
            | start | end   |
            | 11:30 | 11:45 |
            | 12:00 | 12:40 |
            | 11:15 | 14:15 |

    Scenario: Create several time frames in the same shift
        When I create a lunch time frame from "11:30" to "11:45"
        And I create a lunch time frame from "12:00" to "12:30"
        And I click on the save configuration button
        Then I should see 2 time frames in the lunch shift

    # Negative Scenarios
    Scenario Outline: Invalid time frame
        When I create a lunch time frame from "<start>" to "<end>"
        And I click on the save configuration button
        Then I should see an invalid time frame message

        Examples:
            | start | end   | reason                     |
            | 10:00 | 10:30 | outside the lunch shift    |
            | 14:00 | 14:30 | ends after the lunch shift |
            | 12:30 | 12:00 | ends before it starts      |
            | 12:00 | 12:00 | zero duration              |
