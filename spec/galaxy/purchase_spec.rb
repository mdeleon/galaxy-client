require File.expand_path('../../../spec_helper', __FILE__)
require "galaxy/models/purchase"

describe Galaxy::Purchase do
  describe "#checkout" do
    it "sends PUT to /purchases/:id/checkout.json"
  end
end
