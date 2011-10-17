require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/models/credit_card"

describe Galaxy::CreditCard do
  describe "#make_primary" do
    it "sends PUT to /credit_cards/:id/make_primary.json"
  end
end
