Feature: FastPass pass
    As a student who won the FastPass raffle
    I want to see my FastPass pass and free my spot if I cannot go
    So that I know when and where to enter, and another student can use my spot

    Background:
        Given I am logged in as a student
        And I have a lunch FastPass pass
        And I am on the "Sorteio e Gestão do FastPass" page

    # Positive Scenarios
    Scenario: See my FastPass pass
        Then I should see my FastPass timeslot
        And I should see my FastPass turnstile
        And I should see my FastPass QR code

    Scenario: Free my spot
        When I click on the free my spot button
        Then I should see the FastPass spot freed message
        And I should not see my FastPass QR code

    # Negative Scenarios
    Scenario: Miss my timeslot without freeing the spot
        Given it is after my FastPass timeslot end
        And I did not use my FastPass pass
        Then I should see the FastPass blocked for 24 hours message
