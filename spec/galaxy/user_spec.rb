require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/user"

describe Galaxy::User do
  let(:user_hash) { { id: "ABC123", email: "test@test.com", postal_code: "94110", firstname: "foo", credits: 0, share_link: "whatevers" } }
  let(:users_ary) { { :users => [user_hash] } }
  let(:http_ok)   { { :status => 'success' } }

  describe ".find_by_token" do
    it "sends GET to /users/find_by_token.json" do
      mock_galaxy(:get, "/api/v2/users/find_by_token.json?token=123", get_headers, users_ary.to_json, 200)
      Galaxy::User.find_by_token("123").first.id.should eql "ABC123"
    end
  end

  describe ".find_by_email" do
    it "sends GET to /users/find_by_email.json" do
      mock_galaxy(:get, "/api/v2/users/find_by_email.json?email=test%40test.com", get_headers, users_ary.to_json, 200)
      Galaxy::User.find_by_email("test@test.com").first.id.should eql "ABC123"
    end
  end

  describe "#reset_password" do
    let(:params) {
      {
        token: 'token',
        pass: 'password',
        pass_confirmation: "password confirmation"
      }
    }
    it "sends PUT to /users/:id/reset_password.json" do
      user = Galaxy::User.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/users/d02k49d/reset_password.json?pass=password&pass_confirmation=password&token=token", post_headers, http_ok, 200)
      response = user.reset_password("token", "password", "password")
      response.body[:status] == 'success'
    end
  end

  describe "#blacklist" do
    it "sends PUT to /users/:id/blacklist.json" do
      user = Galaxy::User.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/users/#{user.id}/blacklist.json", post_headers, http_ok, 200)
      response = user.blacklist
      response.body[:status] == 'success'
    end
  end
end
