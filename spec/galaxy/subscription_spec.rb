require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  describe "#subscribe" do
    before(:all) do
      @subscription_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/subscriptions/#{@subscription_id}/subscribe.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /subscriptions/:id/subscribe.json" do
      subscription = Galaxy::Subscription.new(:id => @subscription_id)
      subscription.subscribe
    end
  end

  describe "#unsubscribe" do
    before(:all) do
      @subscription_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/subscriptions/#{@subscription_id}/unsubscribe.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /subscriptions/:id/unsubscribe.json" do
      subscription = Galaxy::Subscription.new(:id => @subscription_id)
      subscription.unsubscribe
    end
  end

  describe "#pause" do
    before(:all) do
      @subscription_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/subscriptions/#{@subscription_id}/pause.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /subscriptions/:id/pause.json" do
      subscription = Galaxy::Subscription.new(:id => @subscription_id)
      subscription.pause
    end
  end
end
