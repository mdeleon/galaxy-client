require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/email"

describe Galaxy::Email do
  describe ".invite" do
    before(:all) do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post("/api/v2/emails/invite.json?emails%5B%5D=bar1%40example.com&emails%5B%5D=bar2%40example.com&from=foo%40example.com&msg=Hello+World%21",
                  post_headers, nil, 200)
      end
    end

    it "sends POST to /emails/invite.json with params" do
      Galaxy::Email.invite("foo@example.com", ["bar1@example.com", "bar2@example.com"], "Hello World!")
    end
  end

  describe ".recommend_deal" do
    before(:all) do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post("/api/v2/emails/recommend_deal.json?deal_id=the-big-deal&emails%5B%5D=bar1%40example.com&emails%5B%5D=bar2%40example.com&from=foo%40example.com&msg=Hello+World%21",
                  post_headers, nil, 200)
      end
    end

    it "sends POST to /emails/recommend_deal.json with params" do
      Galaxy::Email.recommend_deal("foo@example.com", ["bar1@example.com", "bar2@example.com"], "the-big-deal", "Hello World!")
    end
  end
end
