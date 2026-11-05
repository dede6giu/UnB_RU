Feature: Turnstile management
    As an administrator
    I want to add turnstiles to restaurants
    So that employees can choose them in the control application

    Background:
        Given there are restaurants with turnstiles
        And I am logged in as an admin
        And I am on the "Cadastrar Catraca" page
        And I know a restaurant
        And I choose a restaurant knowingly

    # Positive Scenarios
    Scenario: Add a turnstile to a restaurant
        When I fill in "turnstile-name" unknowingly
        And I click the create turnstile button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new "turnstile-name"
        And the new "turnstile-name" should be ready

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
        And I should see a already existing turnstile message