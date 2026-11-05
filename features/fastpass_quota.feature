Feature: FastPass quotas
    As an administrator
    I want to define how many FastPass spots each time frame offers
    So that the raffle does not give out more passes than the turnstiles can handle

    Background:
        Given I am logged in as an admin
        And the FastPass turnstile handles 40 students per 15 minutes
        And the lunch shift has a time frame from "12:00" to "12:15"
        And I am on the "Vagas e Cotas FastPass" page

    # Positive Scenarios
    Scenario: Set the quota of a time frame
        When I set the quota of the "12:00" to "12:15" time frame to "40"
        And I click on the apply quotas to the next raffle button
        Then I should see a quota of "40" passes in the "12:00" to "12:15" time frame

    Scenario: Restore the default quotas
        Given the "12:00" to "12:15" time frame has a quota of "10" passes
        When I click on the restore defaults button
        Then I should see the default quota in the "12:00" to "12:15" time frame

    Scenario: The raffle gives at most the quota
        Given the "12:00" to "12:15" time frame has a quota of "2" passes
        And 3 students entered the raffle for the "12:00" to "12:15" time frame
        When the raffle happens
        Then 2 students should win a FastPass for the "12:00" to "12:15" time frame

    # Negative Scenarios
    Scenario Outline: Invalid quota
        When I set the quota of the "12:00" to "12:15" time frame to "<quota>"
        And I click on the apply quotas to the next raffle button
        Then I should see an invalid quota message

        Examples:
            | quota | reason                            |
            | 0     | below one spot                    |
            | -5    | negative                          |
            | abc   | not a number                      |
            | 41    | above the safe turnstile capacity |
