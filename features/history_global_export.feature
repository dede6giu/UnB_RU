Feature: Export the global report as PDF
    As an admin
    I want to export the global operation report as a PDF
    So that I can use it in internal audits

    Background:
        Given I am logged in as an admin

    # Positive Scenarios
    Scenario: Export my Relatório Global de Operação
        Given I am logged in as an admin
        And I am on the "Relatório Global de Operação" page
        When I click on "Exportar PDF Oficial"
        Then a PDF file containing my "Relatório Global de Operação" should be downloaded

    Scenario: The PDF follows the active filter
        Given there is access history in "RU Darcy Ribeiro" and "RU Gama"
        When I go to the "Relatório Global de Operação" page
        And I filter by restaurant "RU Gama"
        And I click the export PDF button
        Then the PDF should only contain the accesses of restaurant "RU Gama"

    Scenario: The PDF shows the export date and the filters used
        Given there is access history in "RU Darcy Ribeiro" and "RU Gama"
        When I go to the "Relatório Global de Operação" page
        And I filter by restaurant "RU Gama"
        And I click the export PDF button
        Then the PDF should show today's date
        And the PDF should show the filter by restaurant "RU Gama"

    # Negative Scenarios
    Scenario: Try to export with no associated data
        Given I am logged as an admin
        And I am on the "Relatório Global de Operação" page
        When I click on the export extract button
        Then I should see a no exctract to export message

    Scenario: Filter with no results
        Given there is access history in "RU Darcy Ribeiro" and "RU Gama"
        When I go to the "Relatório Global de Operação" page
        And I filter by a restaurant with no accesses
        And I click the export PDF button
        Then I should see a no report data to export message
