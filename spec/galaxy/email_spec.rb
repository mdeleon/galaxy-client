require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/email"

describe Galaxy::Email do
  describe ".invite" do
    it "sends POST to /emails/invite.json with params" do
      mock_galaxy(:post, "/api/v2/emails/invite.json?emails%5B%5D=bar1%40example.com&emails%5B%5D=bar2%40example.com&message=Hello+World%21&user_id=d92kd030", post_headers, nil, 200)
      Galaxy::Email.invite({:user_id => "d92kd030", 
                            :emails => ["bar1@example.com", "bar2@example.com"], 
                            :message => "Hello World!"})
    end
  end

  describe ".recommend_deal" do
    let(:params) {
      {
        :user_id => "foo@example.com",
        :emails => ["bar1@example.com", "bar2@example.com"],
        :deal_id => "the-big-deal",
        :message => "Hello World!"
      }
    }
    it "sends POST to /emails/recommend_deal.json with params" do
      mock_galaxy(:post, "/api/v2/emails/recommend_deal.json?deal_id=the-big-deal&emails%5B%5D=bar1%40example.com&emails%5B%5D=bar2%40example.com&message=Hello+World%21&user_id=foo%40example.com", post_headers, nil, 200)
      Galaxy::Email.recommend_deal({
        :user_id => "foo@example.com",
        :emails => ["bar1@example.com", "bar2@example.com"],
        :deal_id => "the-big-deal",
        :message => "Hello World!"
      })
    end
  end
end
