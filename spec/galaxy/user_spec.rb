require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/user"

describe Galaxy::User do
  describe ".create" do
    it "succeeds" do
      stub_request(:post, /.*\/users.*/).to_return(fixture("users/create_valid.json"))

      sub = Galaxy::Subscription.create(:email => "foo@bar.com")
      sub.id.should be
    end

    it "succeeds for any 200 response code" do
      stub_request(:post, /.*\/users.*/).to_return(fixture("users/create_accepted.json"))

      sub = Galaxy::Subscription.create(:user_id => "DEFG1234", :postal_code => "94110")
      sub.id.should be
    end

    it "raises a ValidationError on 422 responses" do
      stub_request(:post, /.*\/users.*/).to_return(fixture("users/create_invalid.json"))

      expect { Galaxy::Subscription.create(:user_id => "", :postal_code => "") }.to raise_error Galaxy::ValidationError
    end
  end
end
