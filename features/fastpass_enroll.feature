Feature: FastPass enrollment
    As a student
    I want to enroll on the free FastPass program choosing one timeslot per meal, so I can have quicker access on the restaurant

    Background:
        Given I am logged in as a student
        And I am on the "Sorteio e Gestão do FastPass" page

    # Positive Scenarios
    Scenario: Try to enter the breakfast raffle (without a ticket)
        Given it is 04:45
        When I choose a valid restaurant
        And I choose a valid timeslot
        And I click on the enter FastPass button
        Then I should see the FastPass enroll success message

    # Negative Scenarios
    Scenario: Try to enter the breakfast raffle (with a ticket)
        Given it is 05:02
        And I have a FastPass ticket
        When I choose a valid restaurant
        And I choose a valid timeslot
        And I click on the enter FastPass button
        Then I should see the already on FastPass raffle message
