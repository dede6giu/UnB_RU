Feature: Turnstile editing
    As an admin
    I want to edit a turnstile
    So that its information stays updated

    Background:
        Given I am an admin
        And there are restaurants
        And there are turnstiles
        And I know a turnstile
        And I am on a knowing turnstile edit page

    # Positive scenarios
    Scenario Outline: Altering between active and inactive
        Given the turnstile I know is <now>
        When from the "turnstile_operation" dropdown I choose "<new_str>"
        And I fill in "turnstile_name" from a known turnstile
        And from the "turnstile_restaurant_id" dropdown I choose from a known turnstile
        And I click the save turnstile button
        Then the turnstile I know should be <new_mode>

        Examples:
            | now      | new_mode | new_str |
            | active   | inactive | Inativa |
            | inactive | active   | Ativa   |

    Scenario: Rename turnstile
        When I fill "turnstile_name" avoiding all turnstiles
        And I click the save turnstile button
        Then I should see the new "turnstile_name"

    # Negative scenarios
    Scenario: Rename turnstile to an already existing turnstile
        Given I learn another turnstile
        When I fill "turnstile_name" from another turnstile
        And from the "turnstile_restaurant_id" dropdown I choose from another turnstile
        And from the "turnstile_operation" dropdown I choose anything
        And I click the save turnstile button
        Then I should see an existing turnstile message

    Scenario: Rename turnstile with an invalid name
        When I fill "turnstile_name" incorrectly
        And I click the save turnstile button
        Then I should see an turnstile name is empty message

    Scenario Outline: Deactivate a turnstile in operation
        Given the turnstile I know is <curr_mode>
        And the turnstile I know has an operator associated to it
        When from the "turnstile_operation" dropdown I choose "<new_str>"
        And I fill in "turnstile_name" from a known turnstile
        And from the "turnstile_restaurant_id" dropdown I choose from a known turnstile
        And I click the save turnstile button
        Then the turnstile I know should be <curr_mode>
        And I should see a turnstile in operation message

        Examples:
            | curr_mode | new_str |
            | operating | Ativa   |
            | operating | Inativa |
            | fastpass  | Ativa   |
            | fastpass  | Inativa |