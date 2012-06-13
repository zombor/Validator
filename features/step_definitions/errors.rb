Then /^the errors should be empty$/ do
  @validator.valid?
  @validator.errors.should be_empty
end

Then /^the errors should contain:$/ do |table|
  @validator.valid?
  table.raw.each do |line|
    @validator.errors[line[0].to_sym].should == eval(line[1])
  end
end
