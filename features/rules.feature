Feature: Rules

  Scenario: Accepts rules from the Validator::Rules namespace
    Given I have a validation object with the following data:
      | id         | 1           |
      | email      | foo@bar.com |
      | password   | foobar      |
      | first_name | foo         |
      | last_name  | bar         |
    When I add a "not_empty" rule for the "email" field
    Then the validation object should be valid
