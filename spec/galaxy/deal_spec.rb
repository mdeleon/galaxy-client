require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/deal"

describe Galaxy::Deal do
  describe "#secondary_deals" do
    before(:all) do
      @secondary_deals = [{ :id => "some deal" }]
      @deal_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get("/api/v2/deals/#{@deal_id}/secondary_deals.json",
                 get_headers, { :deals => @secondary_deals }.to_json, 200)
      end
    end

    it "sends GET to /deals/:id/secondary_deals.json" do
      deal = Galaxy::Deal.new(:id => @deal_id)
      deal.secondary_deals
    end
  end
end
