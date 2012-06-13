Then /^the errors should be empty$/ do
  @validator.valid?
  @validator.errors.should be_empty
end

Then /^the errors should contain:$/ do |table|
  @validator.valid?
  table.raw.each do |line|
    @validator.errors[line[0].to_sym].should == line[1].to_sym
  end
end
