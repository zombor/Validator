Given /^I have a validation object with the following data:$/ do |table|
  data = {}
  table.raw.each do |key, value|
    data[key] = value
  end
  @validator = Validator.new(OpenStruct.new(data))
end

When /^I add a "([^"]*)" rule for the "([^"]*)" field$/ do |rule, field|
  @validator.rule(field.to_sym, rule.to_sym)
end

Then /^the validation object should be valid$/ do
  @validator.valid?.should be_true
end

Then /^the validation object should be invalid$/ do
  @validator.valid?.should be_false
end
