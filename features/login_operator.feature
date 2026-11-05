Feature: Login as an operator
    As an operator
    I want to login to my account so I can operate a turnstile

    Background:
        Given there is operators
        And I am on the "Autenticação do Operador" page

    # Positive scenario
    Scenario: Valid operator login
        Given I know an operator
        When I fill "operator-user" knowingly
        And I fill "operator-pass" knowingly
        And I click on the login button
        Then I should be authenticated in my operator account
        And I should be on the "Configuração de Ponto" page

    # Negative scenario
    Scenario: Invalid operator ID
        When I fill "operator-user" incorrectly
        And I fill "operator-pass" correctly
        And I click on the login button
        Then I should be on the "Autenticação do Operador" page
        And I should see a invalid operator id message

    Scenario: Incorrect password
        Given I know an operator
        When I fill "operator-id" knowingly
        And I fill "operator-pass" unknowingly
        And I click on the login button
        Then I should be on the "Autenticação do Operador" page
        And I should see a incorrect credentials message

    Scenario: Non-existing operator ID
        Given I know all operators
        When I fill "operator-id" unknowingly
        And I fill "operator-pass" correctly
        And I click on the login button
        Then I should be on the "Autenticação do Operador" page
        And I should see a incorrect credentials message