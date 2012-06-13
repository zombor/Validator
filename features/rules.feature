Feature: Rules

  Background:
    Given I have a validation object with the following data:
      | id         | 1           |
      | email      | foo@bar.com |
      | password   | foobar      |
      | first_name |             |
      | last_name  | bar         |

  Scenario: Accepts rules from the Validator::Rules namespace
    When I add a "not_empty" rule for the "email" field
    Then the validation object should be valid

  Scenario: Fails validation when a rule fails
    When I add a "not_empty" rule for the "first_name" field
    Then the validation object should be invalid
