Feature: Public menu page
    As someone visiting the site
    I want to see the restaurant menu without logging in
    So that I can check the food before creating an account

    Background:
        Given I am at the "Cardápio" page

    Scenario Outline: See the breakfast menu being served
        Given today is <weekday> during breakfast time
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

    Scenario Outline: See the lunch menu being served
        Given today is <weekday> during lunch time
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

    Scenario Outline: See the dinner menu being served
        Given today is <weekday> during dinner time
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

    Scenario Outline: See another day of the week
        When I choose <weekday> from "cardapio-weekday"
        Then I should see all menus for <weekday>

        Examples:
            | weekday   |
            | Sunday    |
            | Monday    |
            | Tuesday   |
            | Wednesday |
            | Thursday  |
            | Friday    |
            | Saturday  |