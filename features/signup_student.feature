Feature: Student Account Creation
    As a new student
    I want to use my ID to create an account on the system, so I can have access to the restaurant.

    Background:
        Given I am at the "Cadastro Estudantil" page

    # Positive tests
    Scenario: Correctly register a brand account
        When I fill "student-user" correctly
        And I fill "student-name" correctly
        And I fill "student-pass" correctly
        And I click on the register button
        Then I should be authenticated
        And I should be on the "Portal do Estudante" page
        And I should have no balance

    # Negative tests
    Scenario: Account already exists
        Given there is students
        When I fill "student-user" with existing data
        And I fill "student-name" correctly
        And I fill "student-pass" correctly
        And I click on the register button
        Then I should be on the "Cadastro Estudantil" page
        And I should see an already existing student message

    Scenario: Invalid student ID
        When I fill "student-user" incorrectly
        And I fill "student-name" correctly
        And I fill "student-pass" correctly
        And I click on the register button
        Then I should be on the "Cadastro Estudantil" page
        And I should see an invalid student id message

    Scenario: Empty name
        When I fill "student-user" correctly
        # And I leave "student-name" empty
        And I fill "student-pass" correctly
        And I click on the register button
        Then I should be on the "Cadastro Estudantil" page
        And I should see an invalid student id message

    Scenario: Invalid password
        When I fill "student-user" correctly
        And I fill "student-name" correctly
        And I fill "student-pass" incorrectly
        And I click on the register button
        Then I should be on the "Cadastro Estudantil" page
        And I should see an invalid password message