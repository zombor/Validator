Feature: Rules

  Background:
    Given I have a validation object with the following data:
      | id         | 1           |
      | email      | foo@bar.com |
      | password   | foobar      |
      | first_name |             |
      | last_name  | bar         |

  Scenario: Passes validation when a rule passes
    When I add a "not_empty" rule for the "email" field
    Then the validation object should be valid

  Scenario: Passes validation when multiple rules pass
    When I add the following rules:
      | email    | not_empty |                 |
      | password | length    | {:minimum => 3} |
    Then the validation object should be valid

  Scenario: Fails validation when a rule fails
    When I add a "not_empty" rule for the "first_name" field
    Then the validation object should be invalid

  Scenario: Fails validation when a rule fails and others pass
    When I add a "not_empty" rule for the "first_name" field
    And I add a "not_empty" rule for the "last_name" field
    Then the validation object should be invalid
