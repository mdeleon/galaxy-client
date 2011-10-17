require File.expand_path('../../../spec_helper', __FILE__)
require "galaxy/models/region"

describe Galaxy::Region do
  describe "#current_deal" do
    it "sends GET to /regions/:id/current_deal.json"
  end
end
