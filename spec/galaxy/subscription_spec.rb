require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  describe ".create" do
    it "succeeds" do
      stub_request(:post, /.*\/subscriptions.*/).to_return(fixture("subscriptions/create_valid.json"))

      sub = Galaxy::Subscription.create(:user_id => "DEFG1234", :postal_code => "94110")
      sub.id.should be
    end

    it "succeeds for any 200 response code" do
      stub_request(:post, /.*\/subscriptions.*/).to_return(fixture("subscriptions/create_accepted.json"))

      sub = Galaxy::Subscription.create(:user_id => "DEFG1234", :postal_code => "94110")
      sub.id.should be
    end
  end
end
