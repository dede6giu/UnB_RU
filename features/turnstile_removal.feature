Feature: Turnstile removal
    As an admin
    I want to remove a turnstile
    So that operators only see turnstiles that really exist

    Background:
        Given I am an admin
        And there are restaurants
        And there are turnstiles
        And I know a turnstile
        And I am on a knowing turnstile edit page

    # Positive scenarios
    @javascript
    Scenario Outline: Remove a non-operational turnstile
        When the turnstile I know is <operation>
        And I click the remove turnstile link, and confirm
        Then I should not see the turnstile I know

        Examples:
            | operation |
            | inactive  |
            | active    |

    # Negative scenarios
    @javascript
    Scenario: Give up mid-removal
        When I click the remove turnstile link, and cancel
        And I go to the "Gestão de Restaurantes e Catracas" page
        Then I should see the turnstile I know

    @javascript
    Scenario: Turnstile in operation
        Given the turnstile I know is operating
        When I click the remove turnstile link, and confirm
        Then I should see a turnstile in operation message