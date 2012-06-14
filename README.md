# Validator

Validator is a simple ruby validation class. You don't use it directly inside your classes like just about every other ruby validation class out there. I chose to implement it in this way so I didn't automatically pollute the namespace of the objects I wanted to validate.

This also solves the problem of validating forms very nicely. Frequently you will have a form that represents many different data objects in your system, and you can pre-validate everything before doing any saving.

## Usage

Validator is useful for validating the state of any existing ruby object.

```ruby
  object = OpenStruct.new(:email => 'foo@bar.com', :password => 'foobar')
  validator = Validator.new(object)
  validator.rule(:email, [:email, :not_empty]) # multiple rules in one line
  validator.rule(:password, :not_empty) # a single rule on a line
  validator.rule(:password, :length => {:minimum => 3}) # a rule that takes parameters

  if validator.valid?
    # save the data somewhere
  else
    @errors = validator.errors
  end
```

The first paramater can be any message that the object responds to.

### Writing your own rules

If you have a custom rule you need to write, just put it inside the `Validation::Rule` namespace:

```ruby
  class Validator
    module Rule
      class MyCustomRule
        def error_key
          :my_custom_rule
        end

        def valid_value?(value)
          # Logic for determining the validity of the value
        end

        def params
          {}
        end
      end
    end
  end
```

A rule class should have the following methods on it:

  - `error_key` a symbol to represent the error. This shows up in the errors hash
  - `valid_values?(value)` the beef of the rule. This is where you determine if the value is valid or not
  - `params` the params hash that was passed into the constructor

# Todo

It works as is right now, but I need to add capability for rules to look at other parts of the source object. This will let you do complicated rule logic.
