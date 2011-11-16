require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/credit_card"

describe Galaxy::CreditCard do
  describe "#make_primary" do
    it "sends PUT to /credit_cards/:id/make_primary.json" do
      credit_card = Galaxy::CreditCard.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/credit_cards/#{credit_card.id}/make_primary.json", post_headers, nil, 200)
      credit_card.make_primary
    end
  end
end
