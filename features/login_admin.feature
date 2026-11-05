Feature: Login as an admin
    As an admin
    I want to login to my account so I can manage restaurants, turnstiles and reports

    Background:
        Given there is admins
        And I am on the "Autenticação de Admin" page

    # Positive Scenarios
    Scenario: Valid admin login
        Given I know an admin
        When I fill "admin-user" correctly
        And I fill "admin-pass" correctly
        And I click on the login button
        Then I should be authenticated in my admin account
        And I should be on the "Gestão de Restaurantes e Catracas" page

    # Negative Scenarios
    Scenario: Invalid admin ID
        When I fill "admin-user" incorrectly
        And I fill "admin-pass" correctly
        And I click on the login button
        Then I should be on the "Autenticação de Admin" page
        And I should see an invalid admin id message

    Scenario: Incorrect password
        Given I know an admin
        When I fill "admin-user" correctly
        And I fill "admin-pass" incorrectly
        And I click on the login button
        Then I should be on the "Autenticação de Admin" page
        And I should see an incorrect credentials message

    Scenario: Non-existing admin ID
        Given I know all admins
        When I fill "admin-user" incorrectly
        And I fill "admin-pass" correctly
        And I click on the login button
        Then I should be on the "Autenticação de Admin" page
        And I should see an incorrect credentials message
