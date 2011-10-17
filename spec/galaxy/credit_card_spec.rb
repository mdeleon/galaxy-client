require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/credit_card"

describe Galaxy::CreditCard do
  describe "#make_primary" do
    before(:all) do
      @credit_card_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/credit_cards/#{@credit_card_id}/make_primary.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /credit_cards/:id/make_primary.json" do
      coupon = Galaxy::CreditCard.new(:id => @credit_card_id)
      coupon.make_primary
    end
  end
end
