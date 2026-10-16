Feature: Export Extrato e Histórico de Refeições
    As a student
    I want to export my Extrato e Histórico de Refeições as a PDF
    So that I can better control my finances

    # Positive Scenarios
    Scenario: Export my Extrato e Histórico de Refeições
        Given I am logged in to my account
        And I am on the "Extrato" page
        When I click on "Exportar PDF"
        Then a PDF file containing my "Extrato e Histórico de Refeições" should be downloaded

    Scenario: Export my Extrato e Histórico de Refeições with a filter
        Given I am logged in to my account
        And I am on the "Extrato" page
        When I filter by the "Almoço" meal type
        And I click on "Exportar PDF"
        Then the PDF should only contain my "Almoço" entries

    # Negative Scenarios
    Scenario: Try to export with no associated data
        Given I am logged as a student
        And I am on the "Extrato" page
        When I click on the export extract button
        Then I should see a no exctract to export message
