# Validator

[![Build Status](https://secure.travis-ci.org/zombor/Validator.png)](http://travis-ci.org/zombor/Validator)

Validator is a simple Ruby validation framework. You don't use it directly inside your classes like just about every other Ruby validation class out there. Instead, you create separate standalone validator classes and pass the objects you want to validate to those. This way the validation logic does not pollute the namespace of the objects you want to validate.

This also solves the problem of validating complex forms very nicely. Frequently you will have a form that represents many different data objects in your system. If each data object has its own embedded validation logic, validating the entire form at once can be challenging. This framework lets you define a single validator for the entire form and pre-validate everything before doing any saving.

## Usage

### Defining validators

There are two ways to define a validator. You can either write a full-blown validator class:

```ruby
class MyValidator
  include Validation::Validator

  rule :name, :not_empty                                    # a single rule
  rule :email, :not_empty, :email                           # multiple rules in one line
  rule :password, :not_empty, :length => { :minimum => 6 }  # a rule that takes parameters
end
```

Or you can create an anonymous validator class using the inline syntax:

```ruby
klass = Validation::Validator.define do
  rule :email, :length => { :minimum => 10 }
  rule :access_code do |value, context|  # custom rule definition
    context.errors << :must_be_all_caps if value != value.upcase
    context.errors << :invalid_length if value.length != 5
  end
end
```

### Using validators

Once you have a validator class, you can instantiate it with the object you want to validate:

```ruby
object = OpenStruct.new(
  name: "John Doe", email: "huh?!",
  password: "1234", access_code: "ABc"
)
validator = MyValidator.new(object)  # or klass.new(object)
```

Checking the validation result:

```ruby
validator.valid?
#=> false

validator.errors
#=> Hash {
#     :email => [
#       #<Validator::Error rule = :email, error = :invalid>,
#       #<Validator::Error rule = :length, error = :too_short>
#     ],
#     :password => [
#       #<Validator::Error rule = :length, error = :too_short>
#     ],
#     :access_code => [
#       #<Validator::Error rule = :custom, error = :must_be_all_caps>,
#       #<Validator::Error rule = :custom, error = :invalid_length>
#     ]
#   }
```

### Built-in rules

Validator comes with a useful set of built-in validation rules. The following rules are available:

#### Not empty

Checks whether the value is present.

```ruby
rule :field, :not_empty
```

**Errors**
* `required` &ndash; if the value is `nil` or responds true to `empty?`

---

#### Length

Validates the length of a string or any other object that responds to `length`.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :length => { :minimum => 6 }
rule :field, :length => { :minimum => 6, :maximum => 20 }
rule :field, :length => { :range => 6..20 }
rule :field, :length => { :exact => 5 }
```

**Parameters**
* `minimum` &ndash; the minimum required length; takes precedence over `range` if both are given
* `maximum` &ndash; the maximum allowed length; takes precedence over `range` if both are given
* `exact` &ndash; requires an exact length; takes precedence over other parameters
* `range` &ndash; shorthand for specifying both `minimum` and `maximum`

**Errors**
* `too_short` &ndash; if the length is smaller than the minimum (or exact) length
* `too_long` &ndash; if the length exceeds the maximum (or exact) length

---

#### Numeric

Validates a number or a numeric string.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :numeric => { :minimum => 1, :maximum => 10 }
rule :field, :numeric => { :range => 1..10 }
rule :field, :numeric => { :decimals => 2 }
```

**Parameters**
* `minimum` &ndash; the minimum allowed value; takes precedence over `range` if both are given
* `maximum` &ndash; the maximum allowed value; takes precedence over `range` if both are given
* `range` &ndash; shorthand for specifying both `minimum` and `maximum`
* `decimals` &ndash; the maximum number of decimals allowed; defaults to `0` (integers only)

**Errors**
* `invalid` &ndash; if the value is not a valid number
* `too_small` &ndash; if the value is smaller than the specified minimum
* `too_long` &ndash; if the value is larger than the specified maximum
* `not_round` &ndash; if the value has more significant decimals than allowed

---

#### Regex

Checks if a string matches a regular expression.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :regex => { :regex => /\A[0-9][a-f]\z/ }
```

**Parameters**
* `regex` &ndash; the regular expression to match against

**Errors**
* `invalid` &ndash; if the string does not match the regular expression

---

#### Matches

Checks if the value of a field matches that of another field.

```ruby
rule :field, :matches => { :field => :other_field }
```

**Parameters**
* `field` &ndash; the method name of the other field

**Errors**
* `mismatch` &ndash; if the values of the two fields do not match

---

#### Email

Checks whether the value is a syntactically valid email address.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :email
```

**Errors**
* `invalid` &ndash; if the value is not a valid email address

---

#### Phone

Checks whether the value is a syntactically valid phone number.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :phone
rule :field, :phone => { :format => :usa }
```

**Parameters**
* `format` &ndash; the format to validate against; defaults to `usa`

**Errors**
* `invalid` &ndash; if the value does not adhere to the specified format

---

#### URI

Checks whether the value is a valid URI.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :uri
rule :field, :uri => { :required_parts => [:host, :path, :query] }
```

**Parameters**
* `required_parts` &ndash; specifies which parts of the URI must be present; defaults to `[:host]`

**Errors**
* `invalid` &ndash; if the value is not a syntactically valid URI, or at least one of its required parts is missing

---

#### Uuid

Checks whether the value is a valid UUID.

**Important:** `nil` and `empty?` objects are always treated as valid. Use the `not_empty` validator to prevent empty values from slipping through.

```ruby
rule :field, :uuid
rule :field, :uuid => { :version => :v4 }
```

**Parameters**
* `version` &ndash; requires a specific UUID version; available options:  `any` (default), `v4`, `v5`

**Errors**
* `invalid` &ndash; if the value is not a valid UUID of the specified version

### Writing your own rules

If you have a custom rule you need to write, you can create a custom rule class for it:

```ruby
  class MyCustomRule
    include Validation::Rule

    # set an identifier for this rule; used in the errors hash
    rule_id :my_custom_rule

    # set the default options (not required)
    default_options(:foo => :bar)  # for static values
    default_options do             # use a block for dynamic evaluation
      { :latest => Time.now }
    end

    # your custom validation logic
    def validate(value, context)
      return if blank?(value)  # you may want to bail on blank values

      context.errors << :some_error if value == "abc"
      context.errors << :other_error if value.nil? && options[:foo] == :bar

      # additional values you can use:
      # - field - the name of the field being validated
      # - options - a hash of all rule parameters (with defaults, if set)
      # - context.object - the object being validated
    end
  end
```

A rule class consists of the following:

  - `rule_id` &ndash; a symbol to identify this error in the errors hash; it is best to use the underscored version of the class name
  - `default_options` (optional) &ndash; sets default parameter values for the rule
  - `validate(value, context)` &ndash; the beef of the rule; holds the validation logic and adds any errors to `context.errors`

### Using custom rules

If you add your custom rule class to the `Validation::Rule` namespace, you can reference it using a symbol:

```ruby
rule :field, :my_custom_rule  # resolves to Validation::Rule::MyCustomRule
rule :field, :my_custom_rule => { :param => :value }
```

Otherwise, just pass in the rule class itself:

```ruby
rule :field, MyProject::CustomRule
rule :field, MyProject::CustomRule => { :param => :value }
```

# Semantic versioning

This project conforms to [semver](http://semver.org/).

# Contributing

Have an improvement? Have an awesome rule you want included? Simple!

 1. Fork the repository
 2. Create a branch off of the `master` branch
 3. Write specs for the change
 4. Add your change
 5. Submit a pull request to merge against the `master` branch

Don't change any version files or gemspec files in your change.
