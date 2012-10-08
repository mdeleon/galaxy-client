require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/purchase"

describe Galaxy::Purchase do
  subject { Galaxy::Purchase.new(:id => "d02k49d", :created_at => nil) }
  
  it_timeifies :created_at
  describe "#checkout" do
    it "sends PUT to /purchases/:id/checkout.json" do
      mock_galaxy(:put, "/api/v2/purchases/#{subject.id}/checkout.json", post_headers, nil, 200)
      subject.checkout
    end
  end
end
