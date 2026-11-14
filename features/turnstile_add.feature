Feature: Turnstile management
    As an administrator
    I want to add turnstiles to restaurants
    So that employees can choose them in the control application

    Background:
        Given I am an admin
        And there are restaurants
        And there are turnstiles
        And I am on the "Cadastrar Catraca" page

    # Positive Scenarios
    Scenario: Add a turnstile to a restaurant
        When I fill in "turnstile_name" avoiding all turnstiles
        And I click the create turnstile button
        Then I should be on the "Gestão de Restaurantes e Catracas" page
        And I should see the new "turnstile_name"

    # Negative Scenarios
    Scenario: Invalid turnstile name
        When I fill in "turnstile_name" incorrectly
        And from the "turnstile_operation" dropdown I choose anything
        And from the "turnstile_restaurant_id" dropdown I choose anything
        And I click the create turnstile button
        Then I should see a turnstile name is empty message

    Scenario: Already existing turnstile
        Given I know a turnstile
        When I fill in "turnstile_name" from a known turnstile
        And from the "turnstile_restaurant_id" dropdown I choose from a known turnstile
        And from the "turnstile_operation" dropdown I choose anything
        And I click the create turnstile button
        Then I should see an existing turnstile message