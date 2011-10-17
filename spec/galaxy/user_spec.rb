require File.expand_path('../../../spec_helper', __FILE__)
require "galaxy/models/user"

describe Galaxy::User do
  describe "#reset_password" do
    it "sends PUT to /users/:id/reset_password.json"
  end

  describe "#blacklist" do
    it "sends PUT to /users/:id/blacklist.json"
  end
end
