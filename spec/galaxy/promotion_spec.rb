require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/promotion"

describe Galaxy::Promotion do
  describe "#apply_to_user" do
    it "sends POST to /promotions/:id/apply_to_user.json with params" do
      promotion = Galaxy::Promotion.new({:id => "d02k49d"}, true)
      mock_galaxy(:post, "/api/v2/promotions/#{promotion.id}/apply_to_user.json?user_id=foo%40example.com", post_headers, nil, 200)
      promotion.apply_to_user("foo@example.com")
    end
  end

 describe "#ended?" do
    it "return true if ended" do
      promotion = Promotion.new(:end_at => Time.now)
      promotion.ended?.should be_true
    end
    it "return false if not ended" do
      promotion = Promotion.new(:end_at => Time.now + 3600)
      promotion.ended?.should be_false
    end
  end

  describe "#sold_out?" do
    it "return true if sold_out" do
      promotion = Promotion.new(:redemptions => 10, :quantity => 10)
      promotion.sold_out?.should be_true
    end
    it "return false if not sold_out" do
      promotion = Promotion.new(:redemptions => 1, :quantity => 10)
      promotion.sold_out?.should be_false
    end
  end

  describe "#started?" do
    it "return true if started" do
      promotion = Promotion.new(:start_at => Time.now)
      promotion.started?.should be_true
    end
    it "return false if not started" do
      promotion = Promotion.new(:start_at => Time.now + 3600)
      promotion.started?.should be_false
    end
  end


  describe "#active?" do
    it "is active if state is active" do
      promotion = Promotion.new(:state => 'active')
      promotion.should be_active
    end

    it "is not active if state is inactive" do
      promotion = Promotion.new(:state => 'inactive')
      promotion.should_not be_active
    end

    it "is not active if state is cancelled" do
      promotion = Promotion.new(:state => 'cancelled')
      promotion.should_not be_active
    end
  end

end
