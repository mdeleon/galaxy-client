require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/purchase"

describe Galaxy::Purchase do
  describe "#checkout" do
    before(:all) do
      @purchase_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/purchases/#{@purchase_id}/checkout.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /purchases/:id/checkout.json" do
      purchase = Galaxy::Purchase.new(:id => @purchase_id)
      purchase.checkout
    end
  end
end
