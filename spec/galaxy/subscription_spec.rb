require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  describe "#subscribe" do
    it "sends PUT to /subscriptions/:id/subscribe.json"
  end

  describe "#unsubscribe" do
    it "sends PUT to /subscriptions/:id/unsubscribe.json"
  end

  describe "#pause" do
    it "sends PUT to /subscriptions/:id/pause.json"
  end
end
