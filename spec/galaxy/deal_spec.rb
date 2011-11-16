require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/deal"

describe Galaxy::Deal do
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
end
