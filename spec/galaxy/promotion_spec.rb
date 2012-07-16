require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/promotion"

describe Galaxy::Promotion do
  describe "#apply_to_user" do
    it "sends POST to /promotions/:id/apply_to_user.json with params" do
      promotion = Galaxy::Promotion.new({:id => "d02k49d"}, persisted = true)
      mock_galaxy(:post, "/api/v2/promotions/#{promotion.id}/apply_to_user.json?user_id=foo%40example.com", post_headers, nil, 200)
      promotion.apply_to_user({:user_id => "foo@example.com"})
    end
  end
end
