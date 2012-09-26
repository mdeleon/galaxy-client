require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/region"

describe Galaxy::Region do
  describe "#current_deal" do
    it "sends GET to /regions/:id/current_deal.json" do
      deal = { :deal => { :id => "d9c3k19d" }}
      region = Galaxy::Region.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/regions/#{region.id}/current_deal.json", get_headers, deal.to_json, 200)

      current_deal = region.current_deal
      current_deal.should be_instance_of(Galaxy::Deal)
      current_deal.id.should == "d9c3k19d"
    end
  end

  describe "#deals" do
    it "sends GET to /regions/:id/deals.json" do
      deals = [{ :id => "d9c3k19d" }]
      region = Galaxy::Region.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/regions/#{region.id}/deals.json", get_headers, deals.to_json, 200)

      region = Galaxy::Region.new(:id => region.id)
      response = region.deals
      response.should be_instance_of(Array)
      response.first.should be_instance_of(Galaxy::Deal)
      response.first.id.should ==  "d9c3k19d"
    end
  end

  describe "#from_ip" do
    let(:region_json) {"{\"active\":true,\"slug\":\"san-francisco\",\"name\":\"San Francisco\",\"id\":\"san-francisco\"}"}

    it "sends GET to /regions/from_ip.json" do
      mock_galaxy(:get, "/api/v2/regions/from_ip.json?ip=127.0.0.1", get_headers, region_json, 200)
      response = Galaxy::Region.from_ip('127.0.0.1')
    end

    it "parses json into a region object" do
      response = Galaxy::Region.from_ip('127.0.0.1')
      response.should be_instance_of(Galaxy::Region)
      response.id.should ==  "san-francisco"
    end
  end
end
