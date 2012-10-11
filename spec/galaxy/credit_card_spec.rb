require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/credit_card"

describe Galaxy::CreditCard do
  describe "#make_primary" do
    it "sends PUT to /credit_cards/:id/make_primary.json" do
      credit_card = Galaxy::CreditCard.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/credit_cards/#{credit_card.id}/make_primary.json", post_headers, nil, 200)
      credit_card.make_primary
    end
  end

  describe "#display_number" do
    it "show correct credit card number" do
      credit_card = CreditCard.find 1
      credit_card.display_number.should be == "VISA - 555 4444"
    end

    it "show invalid credit card number" do
      credit_card = CreditCard.find 3
      credit_card.display_number.should == "Undefined Vendor - 75532315"
    end
  end

  describe "#type_name" do
    it "find defined credit card type name" do
      credit_card = CreditCard.find 1
      credit_card.type_name.should be == "VISA"
    end

    it "find undefined credit card type name" do
      credit_card = CreditCard.find 3
      credit_card.type_name.should be == "Undefined Vendor"
    end
  end

end
