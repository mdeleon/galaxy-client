require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/purchase"

describe Galaxy::Purchase do
  describe "#checkout" do
    it "sends PUT to /purchases/:id/checkout.json" do
      purchase = Galaxy::Purchase.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/purchases/#{purchase.id}/checkout.json", post_headers, nil, 200)
      purchase.checkout
    end
  end
end
