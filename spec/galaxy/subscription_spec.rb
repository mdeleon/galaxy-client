require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  let(:user) { double(:user, :id => 'd02k49d')}
  let(:region) { double(:region, :name => 'San Francisco', :id => 'san-francisco') }
  let(:subscription) { s = Galaxy::Subscription.new(:user_id => user.id, :region_id =>region.id,:region_name =>region.name, :zip => "94111") }

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
end
