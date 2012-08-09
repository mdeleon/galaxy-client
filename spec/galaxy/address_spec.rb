require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/address"

describe Galaxy::Address do
  subject {
    Galaxy::Address.new :created_at => nil
  }
  
  it_timeifies :created_at
end