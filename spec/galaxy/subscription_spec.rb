require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
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
end
