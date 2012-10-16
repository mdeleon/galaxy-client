require 'spec_helper'
require "galaxy/reset_token"

describe Galaxy::ResetToken do
  subject {Galaxy::ResetToken.new(:id => 3, :user_id => '123')}
  describe "#user" do
    it "should find a user by Reset_token#user" do
      Galaxy::User.should_receive(:find)
      r = subject.user
    end
  end
end
