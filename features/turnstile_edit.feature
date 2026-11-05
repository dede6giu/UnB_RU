Feature: Turnstile editing
    As an admin
    I want to edit a turnstile
    So that its information stays updated

    Background:
        Given I am logged in as an admin
        And there are restaurants with turnstiles
        And I know a restaurant
        And I know a turnstile from the restaurant I know
        And I am on the knowing "Manejar Catraca" page

    # Positive scenarios
    Scenario: Deactivate a turnstile
        Given the turnstile I know is ready
        When I click the deactivate turnstile button
        Then I should be on the knowing "Manejar Catraca" page
        And I should see the turnstile as inactive

    Scenario: Rename turnstile
        Given I know all turnstile names
        When I fill "turnstile-name" unknowingly
        And I click the rename button
        Then I should be on the knowing "Manejar Catraca" page
        And I should see the new "turnstile-name"

    # Negative scenarios
    Scenario: Rename turnstile to an already existing name
        Given I know another turnstile from the restaurant I know
        When I fill "turnstile-name" with another
        And I click the rename button
        Then I should be on the knowing "Manejar Catraca" page
        And I should see an existing turnstile message

    Scenario: Rename turnstile with an invalid value
        Given I know all turnstile names
        When I fill "turnstile-name" incorrectly
        Then I should be on the knowing "Manejar Catraca" page
        And I should see an invalid turnstile name message

    Scenario: Deactivate a turnstile in operation
        Given the knowing turnstile is operating
        When I click the deactivate turnstile button
        Then I should be on the knowing "Manejar Catraca" page
        And I should see a turnstile in operation message