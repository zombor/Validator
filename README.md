# Validator

[![Build Status](https://secure.travis-ci.org/zombor/Validator.png)](http://travis-ci.org/zombor/Validator)

Validator is a simple ruby validation class. You don't use it directly inside your classes like just about every other ruby validation class out there. I chose to implement it in this way so I didn't automatically pollute the namespace of the objects I wanted to validate.

This also solves the problem of validating forms very nicely. Frequently you will have a form that represents many different data objects in your system, and you can pre-validate everything before doing any saving.

## Usage

Validator is useful for validating the state of any existing ruby object.

```ruby
  object = OpenStruct.new(:email => 'foo@bar.com', :password => 'foobar')
  validator = Validation::Validator.new(object)
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
  module Validation
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

  - `error_key` a symbol to represent the error. This shows up in the errors hash.  Must be an underscored_version of the class name
  - `valid_value?(value)` the beef of the rule. This is where you determine if the value is valid or not
  - `params` the params hash that was passed into the constructor

### Writing self-contained validators

You can also create self-contained validation classes if you don't like the dynamic creation approach:

```ruby
  require 'validation'
  require 'validation/rule/not_empty'

  class MyFormValidator < Validation::Validator
    include Validation

    rule :email, :not_empty
  end
```

Now you can use this anywhere in your code:

```ruby
  form_validator = MyFormValidator.new(OpenStruct.new(params))
  form_validator.valid?
```

# Semantic Versioning

This project conforms to [semver](http://semver.org/).

# Contributing

Have an improvement? Have an awesome rule you want included? Simple!

 1. Fork the repository
 2. Create a branch off of the `master` branch
 3. Write specs for the change
 4. Add your change
 5. Submit a pull request to merge against the `master` branch

Don't change any version files or gemspec files in your change.
