require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/location"

describe Galaxy::Location do
  subject { Galaxy::Location.new :created_at => nil,
                                 :address_id => nil}
  
  it_timeifies :created_at
  
  describe "location" do
    context "address_id is nil" do
      it "returns nil" do
        subject.address.should be_nil
      end
    end
    
    context "address_id exists" do
      it "return the address" do
        subject.address_id = "abc"
        subject.stub_chain(:model_for, :find).and_return :address
        subject.address.should_not be_nil
      end
    end
  end
end