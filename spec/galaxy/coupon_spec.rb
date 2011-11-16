require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/coupon"

describe Galaxy::Coupon do
  describe "#redeem" do
    it "sends PUT to /coupons/:id/redeem.json" do
      coupon = Galaxy::Coupon.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/coupons/#{coupon.id}/redeem.json", post_headers, nil, 200)
      coupon.redeem
    end
  end
end
