Feature: Prize Draw Notification
    As a student
    I want to be notified whether or not I got a FastPass
    one hour before the gates open for the meal,
    so that I can plan when to head to the RU

    Background:
        Given I am a student

    # Positive Scenarios
    Scenario Outline: Drawn student is notified
        Given I enrolled in the <meal> FastPass draw
        And I was drawn
        When it is <notification_time>
        Then I should receive a notification that I got a FastPass

        Examples:
            | meal      | opening_time | notification_time |
            | breakfast | 07:00        | 06:00             |
            | lunch     | 11:15        | 10:15             |
            | dinner    | 17:30        | 16:30             |

    Scenario Outline: Not drawn student is notified
        Given I enrolled in the <meal> FastPass draw
        And I was not drawn
        When it is <notification_time>
        Then I should receive a notification that I did not get a FastPass

        Examples:
            | meal      | opening_time | notification_time |
            | breakfast | 07:00        | 06:00             |
            | lunch     | 11:15        | 10:15             |
            | dinner    | 17:30        | 16:30             |

    # Negative Scenarios
    Scenario: Student not enrolled is not notified
        Given I did not enroll in the lunch FastPass draw
        When it is 10:15
        Then I should not receive any FastPass notification

    Scenario: No notification before the right time
        Given I enrolled in the lunch FastPass draw
        When it is 10:00
        Then I should not receive any FastPass notification yet
