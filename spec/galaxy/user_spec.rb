require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/user"

describe Galaxy::User do
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
