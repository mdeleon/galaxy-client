require 'spec_helper'
require "galaxy/reset_token"

describe Galaxy::ResetToken do
  describe "#user" do
    it "should find a user by Reset_token#user" do
      subject.stub(:user_id => '123')
      Galaxy::User.should_receive(:find).with('123').and_return nil
      r = subject.user
    end
  end
end
