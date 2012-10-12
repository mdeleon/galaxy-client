require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/deal"

describe Galaxy::Deal do

  subject {
    Galaxy::Deal.new :start_at => nil,
    :end_at => nil,
    :expiry_as_of_now => nil,
    :expires_at => nil,
    :expired? => nil,
    :region => nil
  }

  it_timeifies :start_at, :end_at, :expiry_as_of_now, :expires_at

  has_predicate(:approved?).by_field(:state).with_true_value_of("approved")
  has_predicate(:approved?).by_field(:state).with_true_value_of("in-flight")
  has_predicate(:approved?).by_field(:state).with_true_value_of("in-flight")
  has_predicate(:in_flight?).by_field(:state).with_true_value_of("in-flight")
  has_predicate(:redemption_coded?).by_field(:fulfillment_method).with_true_value_of("redemptioncoded")
  has_predicate(:printable?).by_field(:fulfillment_method).with_true_value_of("printed")
  has_predicate(:sent_by_mail?).by_field(:fulfillment_method).with_true_value_of("shipped")
  has_predicate(:card_linked?).by_field(:type).with_true_value_of("card-linked")

  describe ".find_by_regions" do
    let(:deal)  { double(:deal, :card_linked? => false, :soldout => false, :expired? => false, :start_at => 10.days.ago) }
    let(:another_deal)  { double(:deal, :card_linked? => false, :soldout => false, :expired? => false, :start_at => 9.days.ago) }
    let(:offer) { double(:deal, :card_linked? => true, :soldout => false, :expired? => false, :start_at => 8.days.ago) }
    let(:soldout_deal) { double(:deal, :card_linked? => false, :soldout => true, :expired? => false) }
    let(:expired_offer) { double(:deal, :card_linked? => true, :soldout => false, :expired? => true) }

    before do
      Galaxy::Region.stub_chain(:find, :deals).and_return([deal, another_deal, offer, soldout_deal, expired_offer])
    end

    context "when user exists" do
      let(:user) { double :user, :id => 1}

      before do
        user.stub(:fulfilled_deal?).and_return { |d| offer == d ? true : false }
      end

      it "returns sorted inflight deals from regions" do
        expect(Galaxy::Deal.find_by_regions(["denver"], user)).to eq([another_deal, deal])
      end
    end

    context "when user doesn't exist" do
      it "returns sorted inflight deals from regions" do
        expect(Galaxy::Deal.find_by_regions(["denver"])).to eq([offer, another_deal, deal])
      end
    end
  end

  describe "#time_left_hash" do
    it "returns a hash representing time left on a deal" do
      subject.stub(time_left: 871437)
      expect(subject.time_left_hash).to eq({
        days: 10,
        hours: 2,
        minutes: 3,
        seconds: 57,
        total: 871437
      })
    end
  end

  describe "#discount" do
    it "should be the difference of value and price" do
      subject.value = 12345
      subject.price = 12301
      expect(subject.discount).to eq(44)
    end
  end

  describe "#expired?" do
    it "a soldout deal should be expired" do
      subject.stub(:soldout => true)
      subject.should be_soldout
      subject.should be_expired
    end

    it "a ended deal should be expired" do
      subject.stub(:ended? => true, :soldout => false)
      subject.should be_expired
      subject.should be_ended
    end

    it "a not ended and not soldout deal should not be expired" do
      subject.stub(:ended => false, :soldout => false)
      subject.should_not be_expired
    end
  end

  describe "#expired?" do
    context "when the expires_at is nil" do
      it "is not expired" do
        subject.expires_at = nil
        expect(subject).not_to be_expired
      end
    end

    context "when the expires_at is in the future" do
      it "is not expired" do
        subject.expires_at = 2.seconds.from_now
        expect(subject).not_to be_expired
      end
    end

    # context "when the expires_at is in the past" do
    #   it "is expired" do
    #     subject.stub(:soldout => false)
    #     subject.expires_at = 2.seconds.ago
    #     expect(subject).to be_expired
    #   end
    # end
  end

  describe "#calculate_cost" do
    let(:user) {double(:user, :credits => 10000)}
    before {subject.stub(:price => 5000)}

    context "user has credit" do
      it "should return cost" do
        subject.calculate_cost(user, 5).should == [10000, 25000, 15000]
      end
    end

    context "user has not credit" do
      it "should return cost" do
        user.stub(:credits => 0)
        subject.calculate_cost(user, 5).should == [0, 25000, 25000]
      end
    end
  end

  describe "#card_linked?" do
    context "when the type is card-linked" do
      it "is card_linked" do
        subject.type = "card-linked"
        expect(subject).to be_card_linked
      end
    end

    context "when the type is not card-linked" do
      it "is not card_linked" do
        subject.type = "starange thing"
        expect(subject).not_to be_card_linked
      end
    end
  end

  describe "#secondary_deals" do
    it "sends GET to /deals/:id/secondary_deals.json" do
      secondary_deals = [{ :id => "some deal" }]
      deal = Galaxy::Deal.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/deals/#{deal.id}/secondary_deals.json", get_headers, { :deals => secondary_deals }.to_json, 200)

      response = deal.secondary_deals
      response.should be_instance_of(Array)
      response.first.should be_instance_of(Galaxy::Deal)
      response.first.id.should == "some deal"
    end
  end

  describe "#locations" do
    it "sends GET to /deals/:id/locations.json" do
      locations = [{ :id => "some location" }]
      deal = Galaxy::Deal.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/deals/#{deal.id}/locations.json", get_headers, { :locations => locations }.to_json, 200)

      response = deal.locations
      response.should be_instance_of(Array)
      response.first.should be_instance_of(Galaxy::Location)
      response.first.id.should == "some location"
    end
  end

  describe "#started?" do
    it "a started deal should show started" do
      subject.stub(:start_at => 5.days.ago)
      subject.should be_started
    end

    it "a not_started deal should not show started" do
      subject.stub(:start_at => 5.days.from_now)
      subject.should_not be_started
    end
  end

  describe "#running?" do
    it "a not started deal should not show running" do
      subject.stub(:start_at => 5.days.from_now)
      subject.stub(:start_at => 5.days.from_now)
      subject.should_not be_running
    end

    it "a started but not ended deal should show running" do
      subject.stub(:start_at => 5.days.ago)
      subject.stub(:end_at => 4.days.from_now)
      subject.should be_running
    end

    it "a ended deal should not show running" do
      subject.stub(:start_at => 5.days.ago)
      subject.stub(:end_at => 3.days.ago)
      subject.should_not be_running
    end
  end

  describe "#expiry" do
    it "expiry_as_of_now is not nil" do
      subject.stub(:expiry_as_of_now => (Time.now + 3.days))
      subject.expiry(ActiveSupport::TimeZone.new("America/Denver")).zone.should == "MDT"
    end

    it "expiry_as_of_now is nil" do
      subject.stub(:expiry_as_of_now => nil)
      subject.expiry(ActiveSupport::TimeZone.new("America/Denver")).should be == nil
    end
  end

  describe "#buyable?" do
    it "a started and not expired and approved deal can be bought" do
      subject.stub(:start_at => 3.days.ago, :expired? => false, :in_flight? => true, :max_purchasable => 3)
      subject.should be_buyable
    end

    it "a not start deal can not be bought" do
      subject.stub(:start_at => 3.days.from_now, :expired? => false, :in_flight? => true, )
      subject.should_not be_buyable
    end

    it "soldout deal can not be bought" do
      subject.stub(:start_at => 3.days.ago, :max_purchasable => 0, :expired? => false, :in_flight? => true, )
      subject.should_not be_buyable
    end

    it "ended deal can not be bought" do
      subject.stub(:start_at => 3.days.ago, :expired? => true, :in_flight? => true, )
      subject.should_not be_buyable
    end

    it "a unapproved deal can not be bought" do
      subject.stub(:start_at => 3.days.ago, :expired? => false, :in_flight? => false, )
      subject.should_not be_approved
    end
  end

  describe "#product_name" do
    it "show deal title" do
      subject.should_receive(:title).and_return nil
      subject.product_name
    end
  end

  describe "#hide_addresses?" do
    it "should alias" do
      subject.should_receive(:hide_addresses).and_return nil
      subject.hide_addresses?
    end
  end

  describe "#instructions?" do
    context "instructions is blank" do
      it "return false" do
        subject.stub(:instructions).and_return ""
        subject.instructions?.should be_false
      end
    end

    context "instructions is not blank" do
      it "return true" do
        subject.stub(:instructions).and_return "instruction"
        subject.instructions?.should be_true
      end
    end
  end


  describe "#last_purchase and #last_purchase_for_user" do
    let(:user_purchase) { double(:purchase, :deal_id => 2, :created_at => Time.now) }
    let(:deal_purchase) { double(:purchase, :deal_id => 2, :created_at => Time.now) }
    let(:user) {double(:user, :purchases => [user_purchase])}

    before do
      deal_purchase.stub(:deal_id => 2)
      subject.stub(:id => 2, :purchases => [deal_purchase])
    end

    context "#last_purchase" do
      specify {subject.last_purchase == deal_purchase}
    end

    context "last_purchase_for_user" do
      it "should be nil if no user" do
        subject.last_purchase_for_user(nil).should be nil
      end

      it "should be last_purchase for the user" do
        subject.last_purchase_for_user(user).should == user_purchase
      end
    end
  end

  describe "#externalpurchase_url?" do
    it "should show true when external_url is not blank" do
      subject.stub(:external_purchase_url => 'hi')
      subject.external_purchase_url?.should be true
    end

    it "should show false when external_url is blank" do
      subject.stub(:external_purchase_url => nil)
      subject.external_purchase_url?.should be false
    end
  end

  describe "#has_instructions?" do
    context "when there's instruction" do
      it "returns true" do
        subject.stub(:instructions).and_return("abc")
        expect(subject).to have_instructions
      end
    end

    context "when there's no instruction" do
      it "returns false" do
        subject.stub(:instructions).and_return(nil)
        expect(subject).not_to have_instructions
      end
    end
  end

  describe "#national?" do
    it "returns true if the deal's region is 'united-states'" do
      subject.stub_chain(:region, :id).and_return("united-states")
      subject.should be_national
    end

    it "returns false if the deal's region is not 'united-states'" do
      subject.stub_chain(:region, :id).and_return("xyc")
      subject.should_not be_national
    end
  end
end
