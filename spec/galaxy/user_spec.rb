require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/user"

describe Galaxy::User do
  describe ".find_or_create_by_email" do
    before(:all) do
      @user_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post("/api/v2/users/find_or_create_by_email.json?user%5Bemail%5D=foo%40bar.com&user%5Bpostal_code%5D=91210&user%5Bsource%5D=test",
                  post_headers, nil, 200)
      end
    end

    it "sends POST to /users/find_or_create_by_email.json" do
      Galaxy::User.find_or_create_by_email(:email => "foo@bar.com", :postal_code => 91210, :source => "test")
    end
  end

  describe "#reset_password" do
    before(:all) do
      @user_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/users/#{@user_id}/reset_password.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /users/:id/reset_password.json" do
      user = Galaxy::User.new(:id => @user_id)
      user.reset_password
    end
  end

  describe "#blacklist" do
    before(:all) do
      @user_id = "d02k49d"
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put("/api/v2/users/#{@user_id}/blacklist.json",
                 post_headers, nil, 200)
      end
    end

    it "sends PUT to /users/:id/blacklist.json" do
      user = Galaxy::User.new(:id => @user_id)
      user.blacklist
    end
  end
end
