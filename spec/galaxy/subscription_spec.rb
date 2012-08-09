require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  subject { Galaxy::Subscription.new(:id => "d02k49d", :created_at => nil) }
  
  it_timeifies :created_at
  
  describe "#subscribe" do
    it "sends PUT to /subscriptions/:id/subscribe.json" do
      mock_galaxy(:put, "/api/v2/subscriptions/#{subject.id}/subscribe.json", post_headers, nil, 200)
      subject.subscribe
    end
  end

  describe "#unsubscribe" do
    it "sends PUT to /subscriptions/:id/unsubscribe.json" do
      mock_galaxy(:put, "/api/v2/subscriptions/#{subject.id}/unsubscribe.json", post_headers, nil, 200)
      subject.unsubscribe
    end
  end

  describe "#pause" do
    it "sends PUT to /subscriptions/:id/pause.json" do
      mock_galaxy(:put, "/api/v2/subscriptions/#{subject.id}/pause.json", post_headers, nil, 200)
      subject.pause
    end
  end
end
