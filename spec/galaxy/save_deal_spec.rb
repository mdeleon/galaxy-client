require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/saved_deal"

describe Galaxy::SavedDeal do
  subject { Galaxy::SavedDeal.new :created_at => nil }
  
  it_timeifies :created_at
end