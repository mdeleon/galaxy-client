require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/category"

describe Galaxy::Category do
  subject { Galaxy::Category.new :created_at => nil }
  
  it_timeifies :created_at
end