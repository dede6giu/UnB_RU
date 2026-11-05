Feature: Disconnect from a turnstile
    As an operator
    I want to be able to disconnect from a turnstile to exchange turnstiles or end my shift

    Background:
        Given I am an operator
        And I have a turnstile
        And I am on the "Terminal de Validação" page

    # Positive Scenarios
    Scenario: Disconnect from my turnstile
        When I click the disconnect from turnstile button
        And I confirm
        Then I should be on the "Configuração de Ponto" page
        And I should have no turnstile

    # Negative Scenarios
    Scenario: Cancel disconnection
        When I click the disconnect from turnstile button
        And I cancel
        Then I should be on the "Terminal de Validação" page
        And I should have my turnstile