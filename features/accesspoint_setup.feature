Feature: Access point setup
    As an operator
    I want to choose a restaurant and turnstile to operate

    Background:
        Given there are restaurants with turnstiles
        And I am an operator
        And I am on the "Configuração de Ponto" page

    # Positive Scenarios
    Scenario: Choose a restaurant and a ready turnstile
        Given I know an active turnstile
        When I choose a turnstile knowingly
        And I press the start operation button
        Then I should be on the "Terminal de Validação" page
        And I should see my turnstile

    # Negative Scenarios
    Scenario: Choosing no turnstile
        When I press the start operation button
        Then I should be on the "Configuração de Ponto" page
        And I should see the choose a turnstile message

    Scenario: Choosing an inactive turnstile
        Given I know an inactive turnstile
        When I choose a turnstile knowingly
        And I press the start operation button
        Then I should be on the "Configuração de Ponto" page
        And I should see the inactive turnstile message

    Scenario: Choosing an operating turnstile
        Given I know an operating turnstile
        When I choose a turnstile knowingly
        And I press the start operation button
        Then I should be on the "Configuração de Ponto" page
        And I should see the already operating turnstile message