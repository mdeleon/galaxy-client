require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/credit_card"

describe Galaxy::CreditCard do
  subject {
    Galaxy::CreditCard.new(:type => 'visa', :number => '44443332221111', :type_name => 'super')
  }
  describe "#make_primary" do
    it "sends PUT to /credit_cards/:id/make_primary.json" do
      credit_card = Galaxy::CreditCard.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/credit_cards/#{credit_card.id}/make_primary.json", post_headers, nil, 200)
      credit_card.make_primary
    end
  end

  describe "#display_number" do
    it "show correct credit card number" do
      subject.display_number.should be == "VISA - 32221111"
    end
  end

  describe "#type_name" do
    it "find defined credit card type name" do
      subject.type_name.should be == "VISA"
    end

    it "find undefined credit card type name" do
      subject.type = 'undefined vendor'
      subject.type_name.should be == "super"
    end
  end

end
