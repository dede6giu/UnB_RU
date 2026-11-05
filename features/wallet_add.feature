Feature: Add Credit to Wallet
    As a student
    I want to be able to add credit to my wallet via PIX or Credit Card

    Background:
        Given I am a student
        And I have balance
        And I am on the "Recarga de Saldo" page

    # Positive scenarios
    Scenario: Adding via PIX
        When I choose PIX credit option
        And I fill "credit-amount" correctly
        And I click on the confirm transaction button
        Then I should be on the "Extrato de Refeições" page
        And I should see the new PIX extract entry
        And I should see my balance increased by the added amount

    Scenario: Adding via Credit Card
        When I choose the Credit Card credit option
        And I fill "card-number" correctly
        And I fill "card-expire" correctly
        And I fill "card-secure" correctly
        And I fill "credit-amount" correctly
        And I click on the confirm transaction button
        Then I should be on the "Extrato de Refeições" page
        And I should see the new Credit Card extract entry
        And I should see my balance increased by the added amount

    # Negative scenarios
    Scenario Outline: Invalid credit amount
        When I choose <credit> credit option
        And I fill "credit-amount" incorrectly
        And I click on the confirm transaction button
        Then I should be on the "Recarga de Saldo" page
        And I should see a incorrect credit amount message
        And I should see my balance had no change

        Examples:
            | credit      |
            | PIX         |
            | Credit Card |

    Scenario: Invalid Credit Card number
        When I choose Credit Card credit option
        And I fill "card-number" incorrectly
        And I fill "card-expire" correctly
        And I fill "card-secure" correctly
        And I fill "credit-amount" correctly
        And I click on the confirm transaction button
        Then I should be on the "Recarga de Saldo" page
        And I should see a incorrect Credit Card info message
        And I should see my balance had no change

    Scenario: Invalid Credit Card expire date
        When I choose Credit Card credit option
        And I fill "card-number" correctly
        And I fill "card-expire" incorrectly
        And I fill "card-secure" correctly
        And I fill "credit-amount" correctly
        And I click on the confirm transaction button
        Then I should be on the "Recarga de Saldo" page
        And I should see a incorrect Credit Card info message
        And I should see my balance had no change

    Scenario: Invalid Credit Card security number
        When I choose Credit Card credit option
        And I fill "card-number" correctly
        And I fill "card-expire" correctly
        And I fill "card-secure" incorrectly
        And I fill "credit-amount" correctly
        And I click on the confirm transaction button
        Then I should be on the "Recarga de Saldo" page
        And I should see a incorrect Credit Card info message
        And I should see my balance had no change