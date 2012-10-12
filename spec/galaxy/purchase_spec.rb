require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/purchase"

describe Galaxy::Purchase do
  it_timeifies :created_at

  has_predicate(:charged?).by_field(:payment_state).with_true_value_of("charged")
  has_predicate(:active?).by_field(:payment_state).with_true_value_of("active")

  subject { Galaxy::Purchase.new(:created_at => nil)}

  describe "#checkout" do
    it "sends PUT to /purchases/:id/checkout.json" do
      purchase = Galaxy::Purchase.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/purchases/#{purchase.id}/checkout.json", post_headers, nil, 200)
      purchase.checkout
    end
  end

  describe "#amount" do
    it "should show the amount" do
      subject.should_receive(:total).and_return 100
      subject.amount
    end
  end

  describe "#printable?" do
    it "is true when charged? and deal is printable" do
      subject.stub(:charged? => true)
      subject.stub_chain(:deal, :printable?).and_return(true)
      subject.printable?.should be_true
      subject.stub(:charged? => false)
      subject.printable?.should be_false
      subject.stub_chain(:deal, :printable?).and_return(false)
      subject.printable?.should be_false
    end
  end
end

