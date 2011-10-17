require File.expand_path('../../../spec_helper', __FILE__)
require "galaxy/models/coupon"

describe Galaxy::Coupon do
  describe "#redeem" do
    it "sends PUT to /coupons/:id/redeem.json"
  end
end
