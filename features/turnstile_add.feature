Feature: Turnstile management
    As an administrator
    I want to add turnstiles to restaurants
    So that employees can choose them in the control application

    Background:
        Given there are restaurants with turnstiles
        And I am an admin
        And I know a restaurant
        And I am on the "Manejar catraca" page of a restaurant I know

    # Positive Scenarios
    Scenario: Add a turnstile to a restaurant
        Given I know all turnstiles
        When I fill in "turnstile-name" unknowingly
        And I click the create turnstile button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new turnstile
        And the new turnstile should be ready

    # Negative Scenarios
    Scenario: Invalid turnstile name
        When I fill in "turnstile-name" incorrectly
        And I click the create turnstile button
        Then I should be on the "Cadastrar Catraca" page
        And I should see a invalid turnstile name message

    Scenario: Already existing turnstile
        When I fill in "turnstile-name" knowingly
        And I click the create turnstile button
        Then I should be on the "Cadastrar Catraca" page
        And I should see an existing turnstile message