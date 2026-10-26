Feature: View Extrato e Histórico de Refeições
    As a Student
    I want to see my expenses and history of meals

    Background:
        Given I am a student
        And I am on the "Extrato e Histórico de Refeições" page

    # Positive Scenarios
    Scenario: Student with any amount of transactions
        Given I have transaction history
        Then I should see newest entry first

    # Negative Scenarios
    Scenario: Student with no transactions yet
        # Given I have no entries
        Then I should see a no transaction history message