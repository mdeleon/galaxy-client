require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  let(:user) { double(:user, :id => 'd02k49d')}
  let(:region) { double(:region, :name => 'San Francisco', :id => 'san-francisco') }

  let (:sub_hash){{:id => "d02k49d", :created_at => nil}}
  subject { Galaxy::Subscription.new(sub_hash)}
  it_timeifies :created_at

  describe "#pause" do
    it "sends PUT to /subscriptions/:id/pause.json" do
      mock_galaxy(:put, "/api/v2/subscriptions/#{subject.id}/pause.json", post_headers, nil, 200)
      subject.pause
    end
  end

  let(:subscription) { s = Galaxy::Subscription.new(:user_id => user.id, :region_id =>region.id,:region_name =>region.name, :zip => "94111") }
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
