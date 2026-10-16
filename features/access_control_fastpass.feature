Feature: Strict FastPass validation
    As the control application
    I want to check if a FastPass student arrived within their time window
    So that I only allow entry and debit the balance at the right time

    Background:
        Given the turnstile is in FastPass mode
        And the student "Anna" was drawn for the "12:15" to "12:30" window
        And the student "Anna" has "13.50" in credit

    # Positive Scenarios
    Scenario: Student arrives within the time window
        When the student "Anna" scans her QR Code at "12:20"
        Then the turnstile should allow entry
        And the student "Anna" should have "9.00" in credit

    # Negative Scenarios
    Scenario: Student arrives after the time window
        When the student "Anna" scans her QR Code at "12:36"
        Then the turnstile should block entry
        And I should see the outside time window message
        And the student "Anna" should have "13.50" in credit

    Scenario: Student arrives before the time window
        When the student "Anna" scans her QR Code at "12:00"
        Then the turnstile should block entry
        And I should see the outside time window message
        And the student "Anna" should have "13.50" in credit

    Scenario: Student without a FastPass
        Given the student "Bruno" was not drawn
        When the student "Bruno" scans the QR Code at "12:20"
        Then the turnstile should block entry
        And I should see the no FastPass message

    Scenario: FastPass student without enough balance
        Given the student "Anna" has "0.00" in credit
        When the student "Anna" scans her QR Code at "12:20"
        Then the turnstile should block entry
        And I should see the not enough balance message
