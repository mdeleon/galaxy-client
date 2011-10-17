require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/region"

describe Galaxy::Region do
  describe "#current_deal" do
    before(:all) do
      @region_id = "d02k49d"
      @deal = { :id => "d9c3k19d" }

      ActiveResource::HttpMock.respond_to do |mock|
        mock.get("/api/v2/regions/#{@region_id}/current_deal.json",
                 get_headers, @deal.to_json, 200)
      end
    end

    it "sends GET to /regions/:id/current_deal.json" do
      region = Galaxy::Region.new(:id => @region_id)
      region.current_deal
    end
  end
end
