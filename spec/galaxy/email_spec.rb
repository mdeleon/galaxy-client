require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/email"

describe Galaxy::Email do
  describe ".invite" do
    it "sends POST to /emails/invite.json"
    it "encodes params from, to, emails and msg"
  end

  describe ".recommend_deal" do
    it "sends POST to /emails/recommend_deal.json"
    it "encodes params from, to, deal_id and msg"
  end
end
