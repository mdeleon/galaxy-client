require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/promotion"

describe Galaxy::Promotion do
  describe "#apply_to_user" do
    it "description" do
      promotion = Galaxy::Promotion.new({:id => "d02k49d"}, persisted = true)
      mock_galaxy(:post, "/api/v2/promotions/#{promotion.id}/apply_to_user.json", post_headers, nil, 200)
      promotion.apply_to_user
    end
  end
end
