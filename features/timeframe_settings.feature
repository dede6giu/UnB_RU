Feature: FastPass time frame settings
    As an administrator
    I want to configure the FastPass delay tolerance and early release, and turn the tolerance on or off
    So that the turnstiles follow the punctuality rules I choose

    Background:
        Given I am logged in as an admin
        And I am on the "Turnos e Time-frames" page

    # Positive Scenarios
    Scenario: Set the delay tolerance and the early release
        When I fill "fastpass-tolerance" with "3"
        And I fill "fastpass-early-release" with "2"
        And I click on the save configuration button
        Then I should see a delay tolerance of "3" minutes
        And I should see an early release of "2" minutes

    Scenario: Turn the delay tolerance off
        Given the FastPass delay tolerance is turned on
        When I uncheck the delay tolerance checkbox
        And I click on the save configuration button
        Then I should see the delay tolerance turned off

    Scenario: Turn the delay tolerance on
        Given the FastPass delay tolerance is turned off
        When I check the delay tolerance checkbox
        And I click on the save configuration button
        Then I should see the delay tolerance turned on

    # Negative Scenarios
    Scenario Outline: Invalid FastPass setting
        When I fill "<field>" with "<value>"
        And I click on the save configuration button
        Then I should see an invalid FastPass setting message

        Examples:
            | field                  | value | reason       |
            | fastpass-tolerance     | -1    | negative     |
            | fastpass-tolerance     | abc   | not a number |
            | fastpass-early-release | -1    | negative     |
            | fastpass-early-release | abc   | not a number |
