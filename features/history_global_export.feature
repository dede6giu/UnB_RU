Feature: Export the global report as PDF
    As an admin
    I want to export the global operation report as a PDF
    So that I can use it in internal audits

    Background:
        Given I am an admin
        And I am on the "Relatório Global de Operação" page

    # Positive Scenarios
    Scenario: Download Relatório Global de Operação
        Given there is global history
        When I click the export PDF button
        Then a PDF file for the global history downloads

    Scenario Outline: The PDF follows the restaurant filter
        Given there is access history in the restaurants "<filtered>" and "<unfiltered>"
        When I filter by restaurant "<filtered>"
        And I click the export PDF button
        Then a PDF file for the global history downloads
        And the PDF should only contain entries for the restaurant "<filtered>"

        Examples:
        | filtered | unfiltered |
        | Gama     | Darcy      |
        | Careca   | Executivo  |
        | R1       | R2         |

    Scenario: The PDF follows the date filter
        Given there is global history
        And there is global history today
        When I filter by today
        And I click the export PDF button
        Then a PDF file for the global history downloads
        And the PDF should show the filter by date today

    # Negative Scenarios
    Scenario: Try to export with no associated data
        When I click on the export extract button
        Then I should see a no global history message

    Scenario: Filter with no results
        Given there is access history in the restaurant "<r1>"
        When I filter by restaurant "<r2>"
        And I click the export PDF button
        Then I should see a no global history message
