require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/coupon"

describe Galaxy::Coupon do
  describe "#redeem" do
    before(:all) do
      @coupon_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/coupons/#{@coupon_id}/redeem.json",
                  post_headers, nil, 200)
      end
    end

    it "sends PUT to /coupons/:id/redeem.json" do
      coupon = Galaxy::Coupon.new(:id => @coupon_id)
      coupon.redeem
    end
  end
end
