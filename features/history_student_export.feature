Feature: Export Extrato e Histórico de Refeições
    As a student
    I want to export my Extrato e Histórico de Refeições as a PDF
    So that I can better control my finances

    Background:
        Given I am a student
        And I am on the "Extrato e Histórico de Refeições" page

    # Positive Scenarios
    Scenario: Download my transactions
        Given I have transaction history
        When I click the export PDF button
        Then a PDF file for my transaction history downloads

    Scenario Outline: Filter by entry type
        Given I have transaction history
        When I filter by transaction type <type>
        And I click the export PDF button
        Then a PDF file for my transaction history downloads
        And the PDF should only contain entries for the transaction type <type>

        Examples:
        | type      |
        | breakfast |
        | lunch     |
        | dinner    |
        | credit    |
        | meal      |

    # Negative Scenarios
    Scenario: Try to export with no associated data
        When I click the export PDF button
        Then I should see a no transaction history message