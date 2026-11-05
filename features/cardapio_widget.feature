Feature: Widget of the menu of the current meal
    As a student
    I want to see the menu of the next (or current) meal, with the standard, ovo-lacto-vegetarian and strict vegetarian options

    Background:
        Given I am logged as a student
        And I am at the "Portal do Estudante" page

    Scenario Outline: Current meal (breakfast)
        Given it is <weekday> during breakfast time
        Then I should see the breakfast menu for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |

    Scenario Outline: Current meal (lunch)
        Given it is <weekday> during lunch time
        Then I should see the lunch menu for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |

    Scenario Outline: Current meal (dinner)
        Given it is <weekday> during dinner time
        Then I should see the dinner menu for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |

    Scenario Outline: No meal being served (before breakfast)
        Given it is <weekday> before breakfast time
        Then I should see the lunch menu for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |

    Scenario Outline: No meal being served (breakfast to lunch)
        Given it is <weekday> after breakfast and before lunch time
        Then I should see the lunch menu for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |

    Scenario Outline: No meal being served (lunch to dinner)
        Given it is <weekday> after lunch and before dinner time
        Then I should see the dinner menu for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |

    Scenario Outline: No meal being served (after dinner)
        Given it is <weekday> after dinner time
        Then I should see the breakfast menu for <tomorrow>

        Examples:
            | weekday   | tomorrow  |
            | Sunday    | Monday    |
            | Monday    | Tuesday   |
            | Tuesday   | Wednesday |
            | Wednesday | Thursday  |
            | Thursday  | Friday    |
            | Friday    | Saturday  |
            | Saturday  | Sunday    |