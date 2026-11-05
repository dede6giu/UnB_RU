Feature: Access point setup
    As an operator
    I want to choose a restaurant and turnstile to operate

    Background: As a restaurant employee I want to choose the restaurant and the turnstile I will operate right after logging in
        Given there are restaurants with turnstiles
        And I am an employee
        And I am on the "Configuração de Ponto" page

    # Positive Scenarios
    Scenario: Choose a restaurant and a ready turnstile
        Given I know a restaurant
        When I choose a restaurant knowingly
        And I choose a ready turnstile knowingly
        And I press the start operation button
        Then I should be on the "Terminal de Validação" page
        And I should see my turnstile

    # Negative Scenarios
    Scenario: Choosing no restaurant
        When I press the start operation button
        Then I should be on the "Configuração de Ponto" page
        And I should see the choose a restaurant message

    Scenario: Choosing no turnstile
        Given I know a restaurant
        When I choose a restaurant knowingly
        And I press the start operation button
        Then I should be on the "Configuração de Ponto" page
        And I should see the choose a turnstile message

    Scenario: Choosing an inactive turnstile
        Given I know a restaurant
        When I choose a restaurant knowingly
        And I choose an inactive turnstile knowingly
        Then I should be on the "Configuração de Ponto" page
        And I should see the inactive turnstile message

    Scenario: Choosing an operating turnstile
        Given I know a restaurant
        When I choose a restaurant knowingly
        And I choose an operating turnstile knowingly
        Then I should be on the "Configuração de Ponto" page
        And I should see the already operating turnstile message