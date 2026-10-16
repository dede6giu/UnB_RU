Feature: Disconnect from a turnstile
    As an operator
    I want to be able to disconnect from a turnstile to exchange turnstiles or end my shift

    Background:
        Given I am an assigned employee
        And I am on the "Terminal de Validação" page

    # Positive Scenarios
    Scenario: Disconnect from an operating turnstile
        When I click the disconnect from turnstile button
        Then I should be on the "Configuração de Ponto" page
        And I should have no turnstile