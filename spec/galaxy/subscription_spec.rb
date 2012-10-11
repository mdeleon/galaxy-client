require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  let(:user) { User.find(:all).first}
  let(:region) { Region.find("san-francisco") }
  let(:subscription) { s = Subscription.new(:user_id => user.id, :region_id =>region.id,:region_name =>region.name, :zip => "94111"); s.save; s }

  describe "#subscribe" do
    it "sends PUT to /subscriptions/:id/subscribe.json" do
      subscription = Galaxy::Subscription.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/subscriptions/#{subscription.id}/subscribe.json", post_headers, nil, 200)
      subscription.subscribe
    end
  end

  describe "#unsubscribe" do
    it "sends PUT to /subscriptions/:id/unsubscribe.json" do
      subscription = Galaxy::Subscription.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/subscriptions/#{subscription.id}/unsubscribe.json", post_headers, nil, 200)
      subscription.unsubscribe
    end
  end

  describe "#pause" do
    it "sends PUT to /subscriptions/:id/pause.json" do
      subscription = Galaxy::Subscription.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/subscriptions/#{subscription.id}/pause.json", post_headers, nil, 200)
      subscription.pause
    end
  end

  describe "#region_name" do
    it "valid region_name" do
      subscription.region_name.should be == "San Francisco"
    end

    it "nil region_name" do
      subscription.region_name = nil
      subscription.region_name.should be == "United States"
    end
  end

  describe "#region_id" do
    it "normal region" do
      subscription.region_id.should be == "san-francisco"
    end
  end

  describe "#national?" do
    it "region_id be national" do
      subscription.region_id = "united-states"
      subscription.national?.should be true
    end

    it "region_id not be national" do
      subscription.region_id = "not-united-states"
      subscription.national?.should_not be true
    end
  end

  describe "#unsubscribe?" do
    it "unsubscribe successfully" do
       subscription.unsubscribe.should be true
       user.subscriptions.first.status.should == "inactive"
    end
  end
end
