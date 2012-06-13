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

When /^I add the following rules:$/ do |table|
  table.raw.each do |row|
    params = eval(row[2])
    if params.nil?
      @validator.rule(row[0], row[1])
    else
      @validator.rule(row[0], row[1] => params)
    end
  end
end

Then /^the validation object should be valid$/ do
  @validator.valid?.should be_true
end

Then /^the validation object should be invalid$/ do
  @validator.valid?.should be_false
end
