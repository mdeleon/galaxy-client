require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/card_link"

describe Galaxy::CardLink do
  let(:cardlinks) { [{ :id => "d9c3k19d" }] }
  let(:cardlink)  { Galaxy::CardLink.new(:id => "d9c3k19d") }

  describe "#link" do
    it "sends GET to /card_links/:id/link.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink.id}/link.json", get_headers, cardlinks.to_json, 200)
      response = Galaxy::CardLink.new(:id => cardlink.id)
      response.should be_instance_of(Galaxy::CardLink)
      response.id.should == "d9c3k19d"
    end
  end

  describe "#unlink" do
    it "sends GET to /card_links/:id/unlink.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink.id}/unlink.json", get_headers, cardlinks.to_json, 200)
      response = Galaxy::CardLink.new(:id => cardlink.id)
      response.should be_instance_of(Galaxy::CardLink)
      response.id.should == "d9c3k19d"
    end
  end
end
