Given /^an ODataService exists with uri: "([^\"]*)"$/ do |uri|
  @service = OData::Service.new(uri)
end

When /^I call "([^\"]*)" on the service$/ do |method|
  @service_query = @service.send(method)
end

Then /^the result should be "([^\"]*)"$/ do |result|
  @service_result.should == result 
end

Then /^I should be able to call "([^\"]*)" on the service$/ do |method|
  lambda { @service.send(method) }.should_not raise_error
end

Then /^I should not be able to call "([^\"]*)" on the service$/ do |method|
  lambda { @service.send(method) }.should raise_error
end

Then /^I should be able to call "([^\"]*)" on the service with args: "([^\"]*)"$/ do |method, args|
  lambda { @service.send(method, args) }.should_not raise_error
end

When /^I call "([^\"]*)" on the service with args: "([^\"]*)"$/ do |method, args|
  @service_query = @service.send(method, args)
end

When /^I run the query$/ do
  @service_result = @service.execute
end

Then /^the result should be of type "([^\"]*)"$/ do |type|
  @service_result.class.to_s.should == type
end

Then /^the result should have a method: "([^\"]*)"$/ do |method|
  @service_result.respond_to?(method.to_sym).should == true
end

Then /^the method "([^\"]*)" on the result should equal: "([^\"]*)"$/ do |method, value|
  @service_result.send(method.to_sym).should == value
end

Then /^the method "([^\"]*)" on the result should be nil$/ do |method|
  @service_result.send(method.to_sym).should == nil
end

When /^I set "([^\"]*)" on the result to "([^\"]*)"$/ do |property_name, value|
	@service_result.send("#{property_name}=", value)
end

Given /^I expand the query to include "([^\"]*)"$/ do |expands|
  @service_query.expand(expands)
end

When /^I filter the query with: "([^\"]*)"$/ do |filter|
  @service_query.filter(filter)
end


Then /^the method "([^\"]*)" on the result should be of type "([^\"]*)"$/ do |method, type|
  result = @service_result.send(method.to_sym) 
  result.class.to_s.should == type
end

Given /^I call "([^\"]*)" on the service with a new "([^\"]*)" object(?: with (.*))?$/ do |method, object, fields|
  fields_hash = {}
  
  if !fields.nil?
  	fields.split(', ').each do |field|
  	if field =~ /^(?:(\w+): "(.*)")$/
  		key = $1
  		val = $2
  		if val =~ /^@@LastSave$/
  			val = @saved_result
  		end
  		
  		fields_hash.merge!({ key => val })
		else
		end
  	end	
  end
  
  obj = object.constantize.send(:make, fields_hash)
  @service.send(method.to_sym, obj)
end

When /^I save changes$/ do
  @saved_result = @service.save_changes
end

Then /^the save result should be of type "([^\"]*)"$/ do |type|
	@saved_result.class.to_s.should == type
end

When /^I call "([^\"]*)" on the service with the last save result$/ do |method|
  @service.send(method.to_sym, @saved_result)
end

When /^I call "([^\"]*)" on the service with the last query result$/ do |method|
  @service.send(method.to_sym, @service_result)
end

Then /^the save result should equal: "([^\"]*)"$/ do |result|
  @saved_result.to_s.should == result
end

Then /^the method "([^\"]*)" on the save result should equal: "([^\"]*)"$/ do |method, value|
  result = @saved_result.send(method.to_sym)
	result.should == value
end

When /^blueprints exist for the service$/ do
	require File.expand_path(File.dirname(__FILE__) + "../../../test/blueprints")
end

Given /^I call "([^\"]*)" on the service with a new "([^\"]*)" object it should throw an exception with message "([^\"]*)"$/ do |method, object, msg|
	obj = object.constantize.send :make
  lambda { @service.send(method.to_sym, obj) }.should raise_error(msg)
end

Then /^no "([^\"]*)" should exist$/ do |collection|
	@service.send(collection)
	results = @service.execute
	results.should == []
end

Then /^the method "([^\"]*)" on the result's method "([^\"]*)" should equal: "([^\"]*)"$/ do |method, result_method, value|
  obj = @service_result.send(result_method.to_sym)
  obj.send(method.to_sym).should == value
end
