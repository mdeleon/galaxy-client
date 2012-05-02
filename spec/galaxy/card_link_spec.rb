require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/card_link"

describe Galaxy::CardLink do
  let(:cardlink_id) { "d9c3k19d" }
  let(:cardlinks) { [{ :id => cardlink_id }] }
  let(:cardlink)  { Galaxy::CardLink.new(:id => cardlink_id) }

  describe "#link" do
    it "sends GET to /card_links/:id/link.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink_id}/link.json", get_headers, cardlinks.to_json, 200)
      response = Galaxy::CardLink.new(:id => cardlink_id)
      response.should be_instance_of(Galaxy::CardLink)
      response.id.should == cardlink_id
    end
  end

  describe "#unlink" do
    it "sends GET to /card_links/:id/unlink.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink_id}/unlink.json", get_headers, cardlinks.to_json, 200)
      response = Galaxy::CardLink.new(:id => cardlink_id)
      response.should be_instance_of(Galaxy::CardLink)
      response.id.should == cardlink_id
    end
  end
end
