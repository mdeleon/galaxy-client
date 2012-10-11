require 'spec_helper'
require "galaxy/reset_token"

describe Galaxy::ResetToken do
  describe "#user" do
    it "should find a user by Reset_token#user" do
      User.should_receive(:find).with(1).and_return nil
      r = ResetToken.find(1)
    end
  end
end
