require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/location"

describe Galaxy::Location do
  subject { Galaxy::Location.new :created_at => nil }
  
  it_timeifies :created_at
end