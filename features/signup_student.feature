Feature: Student Account Creation
    As a new student
    I want to use my ID to create an account on the system, so I can have access to the restaurant.

    Background:
        Given I am on the "Cadastro Estudantil" page

    # Positive tests
    Scenario: Correctly register a brand account
        When I fill "student_user" correctly
        And I fill "student_name" correctly
        And I fill "student_password" correctly
        And I click on the register button
        Then I should be newly registered
        And I should be on the "Portal do Estudante" page
        And I should have no balance

    # Negative tests
    Scenario: Account already exists
        Given there is students
        And I know a student
        When I fill "student_user" knowingly
        And I fill "student_name" correctly
        And I fill "student_password" correctly
        And I click on the register button
        Then I should see an existing student message

    Scenario Outline: Invalid data input
        When I fill "<correct1>" correctly
        And I fill "<correct2>" correctly
        And I fill "<incorrect>" incorrectly
        And I click on the register button
        Then I should see an <message> message

        Examples:
        | correct1     | correct2         | incorrect        | message               |
        | student_user | student_name     | student_password | too short password    |
        | student_user | student_password | student_name     | student name is empty |
        | student_name | student_password | student_user     | invalid student id    |