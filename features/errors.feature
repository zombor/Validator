Feature: Errors

  Background:
    Given I have a validation object with the following data:
      | id         | 1           |
      | email      | foo@bar.com |
      | password   | foobar      |
      | first_name |             |
      | last_name  | bar         |

  Scenario: Errors are empty when the validation object is valid
    When I add a "not_empty" rule for the "email" field
    Then the errors should be empty

  Scenario: Errors are not empty when the validation object is invalid
    When I add a "not_empty" rule for the "first_name" field
    Then the errors should contain:
      | first_name | {:rule=>:not_empty, :params=>{}} |
