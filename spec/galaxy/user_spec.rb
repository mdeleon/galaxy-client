require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/user"

describe Galaxy::User do
  describe ".create" do
    it "succeeds" do
      stub_request(:post, /.*\/users.*/).to_return(fixture("users/create_valid.json"))

      sub = Galaxy::User.create(:email => "foo@bar.com")
      sub.id.should be
    end

    it "succeeds for any 200 response code" do
      stub_request(:post, /.*\/users.*/).to_return(fixture("users/create_accepted.json"))

      sub = Galaxy::User.create(:email => "foo@bar.com")
      sub.id.should be
    end
  end
end
