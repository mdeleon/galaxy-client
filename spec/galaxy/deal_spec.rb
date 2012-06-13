require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/deal"

describe Galaxy::Deal do
  subject {
    Galaxy::Deal.new :start_at => nil,
    :end_at => nil,
    :expiry_as_of_now => nil
  }

  it_timeifies :start_at, :end_at, :expiry_as_of_now

  describe "#secondary_deals" do
    it "sends GET to /deals/:id/secondary_deals.json" do
      secondary_deals = [{ :id => "some deal" }]
      deal = Galaxy::Deal.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/deals/#{deal.id}/secondary_deals.json", get_headers, { :deals => secondary_deals }.to_json, 200)

      response = deal.secondary_deals
      response.should be_instance_of(Array)
      response.first.should be_instance_of(Galaxy::Deal)
      response.first.id.should == "some deal"
    end
  end

  describe "#locations" do
    it "sends GET to /deals/:id/locations.json" do
      locations = [{ :id => "some location" }]
      deal = Galaxy::Deal.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/deals/#{deal.id}/locations.json", get_headers, { :locations => locations }.to_json, 200)

      response = deal.locations
      response.should be_instance_of(Array)
      response.first.should be_instance_of(Galaxy::Location)
      response.first.id.should == "some location"
    end
  end
end
