require File.expand_path('../../../spec_helper', __FILE__)
require "galaxy/models/deal"

describe Galaxy::Deal do
  describe "#secondary_deals" do
    it "sends PUT to /deals/:id/secondary_deals.json"
  end
end
