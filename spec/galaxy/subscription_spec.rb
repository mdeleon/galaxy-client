require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/subscription"

describe Galaxy::Subscription do
  it ".create" do
    stub_request(:post, /.*\/subscriptions.*/).to_return(fixture("subscription_create_valid.json"))

    sub = Galaxy::Subscription.create(:user_id => "DEFG1234", :postal_code => "94110")
    sub.id.should be
  end
end
