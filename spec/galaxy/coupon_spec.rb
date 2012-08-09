require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/coupon"

describe Galaxy::Coupon do
  subject {  Galaxy::Coupon.new(:id => "d02k49d",
                                :created_at => nil,
                                :redeemed_at => nil,
                                :expires_at => nil) }
  
  it_timeifies :created_at, :redeemed_at, :expires_at
  
  describe "#redeem" do
    it "sends PUT to /coupons/:id/redeem.json" do
      mock_galaxy(:put, "/api/v2/coupons/#{subject.id}/redeem.json", post_headers, nil, 200)
      subject.redeem.code.should eq(200)
    end
  end
end
