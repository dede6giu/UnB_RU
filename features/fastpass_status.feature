Feature: Check what FastPass is active
    As a student
    I want to be able to see which FastPass is active, which is open to enter the raffle, which is inactive, and which is pending use

    Background:
        Given I am logged in as a student
        And I am on the "Sorteio e Gestão do FastPass" page

    # Positive Scenarios
    # After meal end, before the raffle result
    Scenario: Breakfast is open, Lunch is inactive, Dinner is inactive
        Given it is after dinner end time and before breakfast FastPass time
        Then I should see breakfast FastPass is open
        And I should see the breakfast FastPass result time
        And I should see lunch FastPass is inactive
        And I should see dinner FastPass is inactive

    Scenario: Breakfast is inactive, Lunch is open, Dinner is inactive
        Given it is after breakfast end time and before lunch FastPass time
        Then I should see lunch FastPass is open
        And I should see the lunch FastPass result time
        And I should see breakfast FastPass is inactive
        And I should see dinner FastPass is inactive

    Scenario: Breakfast is inactive, Lunch is inactive, Dinner is open
        Given it is after lunch end time and before dinner FastPass time
        Then I should see dinner FastPass is open
        And I should see the dinner FastPass result time
        And I should see breakfast FastPass is inactive
        And I should see lunch FastPass is inactive

    # After the raffle result, before meal start
    Scenario: Breakfast is pending, Lunch is open, Dinner is inactive
        Given it is after breakfast FastPass time and before breakfast start time
        Then I should see lunch FastPass is open
        And I should see the lunch FastPass result time
        And I should see breakfast FastPass is pending
        And I should see dinner FastPass is inactive

    Scenario: Breakfast is inactive, Lunch is pending, Dinner is open
        Given it is after lunch FastPass time and before lunch start time
        Then I should see dinner FastPass is open
        And I should see the dinner FastPass result time
        And I should see lunch FastPass is pending
        And I should see breakfast FastPass is inactive

    Scenario: Breakfast is open, Lunch is incative, Dinner is pending
        Given it is after dinner FastPass time and before dinner start time
        Then I should see breakfast FastPass is open
        And I should see the breakfast FastPass result time
        And I should see dinner FastPass is pending
        And I should see lunch FastPass is inactive

    # After meal start, before meal end
    Scenario: Breakfast is active, Lunch is open, Dinner is inactive
        Given it is after breakfast start time and before breakfast end time
        Then I should see lunch FastPass is open
        And I should see the lunch FastPass result time
        And I should see breakfast FastPass is active
        And I should see dinner FastPass is inactive

    Scenario: Breakfast is inactive, Lunch is active, Dinner is open
        Given it is after lunch start time and before lunch end time
        Then I should see dinner FastPass is open
        And I should see the dinner FastPass result time
        And I should see lunch FastPass is active
        And I should see breakfast FastPass is inactive

    Scenario: Breakfast is open, Lunch is incative, Dinner is active
        Given it is after dinner start time and before dinner end time
        Then I should see breakfast FastPass is open
        And I should see the breakfast FastPass result time
        And I should see dinner FastPass is active
        And I should see lunch FastPass is inactive
