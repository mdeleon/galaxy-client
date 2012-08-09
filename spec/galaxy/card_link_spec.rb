require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/card_link"

describe Galaxy::CardLink do
  let(:cardlink_id) { "d9c3k19d" }
  
  subject { Galaxy::CardLink.new(:id => cardlink_id, :created_at => nil, :fulfilled_at => nil) }
  
  it_timeifies :created_at, :fulfilled_at

  describe "#link" do
    it "sends PUT to /card_links/:id/link.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink_id}/link.json", post_headers, { :linked => true }.to_json, 200)
      cl = subject.link
      cl.linked.should eq true
    end
  end

  describe "#unlink" do
    it "sends PUT to /card_links/:id/unlink.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink_id}/unlink.json", post_headers, { :linked => false }.to_json, 200)
      cl = subject.unlink
      cl.linked.should eq false
    end
  end
end
