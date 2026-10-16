Feature: Login as a Student
    As a recurring student
    I wish to login into my account to see balance, extract, and enter the restaurant.

    Background:
        Given there is students

    # Positive Scenarios
    Scenario: Correctly enter in an existing account
        Given I know a student
        When I fill "student-user" knowingly
        And I fill "student-pass" knowingly
        And I click on the login button
        Then I should be authenticated
        And I should be on the "Portal do Estudante" page

    # Negative tests
    Scenario: Invalid student ID
        When I fill "student-user" incorrectly
        And I fill "student-pass" correctly
        And I click on the login button
        Then I should be on the "Cadastro Estudantil" page
        And I should see an invalid student id message

    Scenario: Incorrect password
        Given I know a student
        When I fill "student-user" knowingly
        And I fill "student-pass" unknowingly
        And I click on the login button
        Then I should be on the "Cadastro Estudantil" page
        And I should see an incorrect credentials message

    Scenario: Non-existing student ID
        Given I know all students
        When I fill "student-user" unknowingly
        And I fill "student-pass" correctly
        And I click on the login button
        Then I should be on the "Autenticação do Operador" page
        And I should see a incorrect credentials message
