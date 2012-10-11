require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/deal"

describe Galaxy::Deal do
  it_timeifies :start_at, :end_at, :expiry_as_of_now

  subject {
    Galaxy::Deal.new :start_at => nil,
    :end_at => nil,
    :expiry_as_of_now => nil
  }

  before do
    Dupe.create :deal, :id => 'denver-deal-not-start', :region_id => 'denver' ,:title => "denver deal #A",:start_at => (1.day.from_now).to_s, :end_at => (2.day.from_now).to_s
    Dupe.create :deal, :id => 'denver-deal-not-end', :region_id => 'denver' ,:title => "denver deal #B",:num_purchased => 5, :num_left => 10, :start_at => (1.day.ago).to_s, :end_at => (2.day.from_now).to_s
    Dupe.create :deal, :id => 'denver-deal-ended', :region_id => 'denver' ,:title => "denver deal #C",:start_at => (2.day.ago).to_s, :end_at => (1.day.ago).to_s
    Dupe.create :deal, :id => 'denver-deal-soldout1-not-end', :region_id => 'denver' ,:title => "denver deal #D", :inventory_limit => 10, :num_purchased => 10, :num_left => 0, :soldout => true, :start_at => (1.day.ago).to_s, :end_at => (2.day.from_now).to_s
    Dupe.create :deal, :id => 'denver-deal-soldout2-ended', :region_id => 'denver' ,:title => "denver deal #E", :inventory_limit => 10, :num_purchased => 10, :num_left => 0, :start_at => (2.day.ago).to_s, :end_at => (1.day.ago).to_s
    Dupe.create :deal, :id => 'denver-deal-external-url', :region_id => 'denver', :external_purchase_url => 'http://www.chase.com'
    Dupe.create :deal, :id => 'denver-deal-no-external-url', :region_id => 'denver', :external_purchase_url => ''
  end

  describe ".find_by_regions" do
    let(:deal)  { double(:deal, :card_linked? => false, :soldout => false, :expired? => false, :start_at => 10.days.ago) }
    let(:another_deal)  { double(:deal, :card_linked? => false, :soldout => false, :expired? => false, :start_at => 9.days.ago) }
    let(:offer) { double(:deal, :card_linked? => true, :soldout => false, :expired? => false, :start_at => 8.days.ago) }
    let(:soldout_deal) { double(:deal, :card_linked? => false, :soldout => true, :expired? => false) }
    let(:expired_offer) { double(:deal, :card_linked? => true, :soldout => false, :expired? => true) }

    before do
      Region.stub_chain(:find, :deals).and_return([deal, another_deal, offer, soldout_deal, expired_offer])
    end

    context "when user exists" do
      let(:user) { double :user, :id => 1}

      before do
        user.stub(:fulfilled_deal?).and_return { |d| offer == d ? true : false }
      end

      it "returns sorted inflight deals from regions" do
        expect(Deal.find_by_regions(["denver"], user)).to eq([another_deal, deal])
      end
    end

    context "when user doesn't exist" do
      it "returns sorted inflight deals from regions" do
        expect(Deal.find_by_regions(["denver"])).to eq([offer, another_deal, deal])
      end
    end
  end


  describe "#expired?" do
    it "a soldout deal should be expired" do
      deal =  Deal.find('denver-deal-soldout1-not-end')
      deal.should be_soldout
      deal.should be_expired
    end

    it "a ended deal should be expired" do
      deal =  Deal.find('denver-deal-ended')
      deal.should be_ended
      deal.should be_expired
    end

    it "a not ended and not soldout deal should not be expired" do
      deal =  Deal.find('denver-deal-not-end')
      deal.should_not be_expired
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

    context "when the expires_at is in the past" do
      it "is expired" do
        subject.expires_at = 2.seconds.ago
        expect(subject).to be_expired
      end
    end
  end

  describe "#calculate_cost" do
    before(:each) do
      Dupe.create :deal, :id => "calculate_cost", :price => 5000
      Dupe.create :user, :id => 2, :email => "calculate_cost@q.com", :credits => 10000
    end

    context "user has credit" do
      it "should return cost" do
        user = User.find_by_email("calculate_cost@q.com").first
        deal = Deal.find("calculate_cost")
        deal.calculate_cost(user, 5).should == [10000, 25000, 15000]
      end
    end

    context "user has not credit" do
      it "should return cost" do
        user = User.find_by_email("calculate_cost@q.com").first
        user.credits = 0
        deal = Deal.find("calculate_cost")
        deal.calculate_cost(user, 5).should == [0, 25000, 25000]
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
      deal =  Deal.find('denver-deal-not-end')
      deal.should be_started
    end

    it "a not_started deal should not show started" do
      deal =  Deal.find('denver-deal-not-start')
      deal.should_not be_started
    end
  end

  describe "#running?" do
    it "a not started deal should not show running" do
      deal =  Deal.find('denver-deal-not-start')
      deal.should_not be_running
    end

    it "a started but not ended deal should show running" do
      deal =  Deal.find('denver-deal-not-end')
      deal.should be_running
    end

    it "a ended deal should not show running" do
      deal =  Deal.find('denver-deal-ended')
      deal.should_not be_running
    end
  end

  describe "#expiry" do
    it "expiry_as_of_now is not nil" do
      deal =  Deal.find('denver-deal-not-end')
      deal.expiry_as_of_now = (Time.now + 3.days).to_s
      deal.expiry(ActiveSupport::TimeZone.new("America/Denver")).zone.should == "MDT"
    end

    it "expiry_as_of_now is nil" do
      deal =  Deal.find('denver-deal-not-end')
      deal.expiry.should be == nil
    end
  end

  describe "#approved?" do
    context "deal can be approved" do
      it "with approved state " do
        deal =  Deal.find('denver-deal-not-end')
        deal.state = "approved"
        deal.should be_approved
      end

      it "with approved state " do
        deal =  Deal.find('denver-deal-not-end')
        deal.state = "in-flight"
        deal.should be_approved
      end

      it "with approved state " do
        deal =  Deal.find('denver-deal-not-end')
        deal.state = "landed"
        deal.should be_approved
      end
    end

    context "deal can not be approved" do
      it "with unapproved state " do
        deal =  Deal.find('denver-deal-not-end')
        deal.state = "unapproved"
        deal.should_not be_approved
      end
    end
  end

  describe "#buyable?" do
    it "a started and not expired and approved deal can be bought" do
      deal =  Deal.find('denver-deal-not-end')
      deal.should be_buyable
    end

    it "a not start deal can not be bought" do
      deal =  Deal.find('denver-deal-not-start')
      deal.should_not be_buyable
    end

    it "soldout deal can not be bought" do
      deal =  Deal.find('denver-deal-soldout1-not-end')
      deal.should_not be_buyable
    end

    it "ended deal can not be bought" do
      deal =  Deal.find('denver-deal-ended')
      deal.should_not be_buyable
    end

    it "a unapproved deal can not be bought" do
        deal =  Deal.find('denver-deal-not-end')
        deal.state = "unapproved"
        deal.should_not be_approved
    end
  end

  describe "#show_closed_at" do
    it "a not end deal should show 1 day ago" do
      deal = Deal.new(:id => 'denver-deal-test', :region_id => 'denver' ,:title => "denver deal #E", :start_at => (Time.now - 2.day).to_s, :end_at => (1.day.from_now).to_s)
      deal.show_closed_at.to_i.should == 1.day.ago.end_of_day.to_i
    end

    it "a ended deal should show self end_at" do
      deal = Deal.new(:id => 'denver-deal-test', :region_id => 'denver' ,:title => "denver deal #E", :start_at => (Time.now - 2.day).to_s, :end_at => (Time.now - 1.day).to_s)
      deal.show_closed_at.should == deal.end_at
    end
  end

  describe "#product_name" do
    it "show deal title" do
      deal =  Deal.find('denver-deal-not-end')
      deal.product_name.should be == deal.title
    end
  end

  describe "#redemption_coded?" do
    it "redemption deal" do
      deal =  Deal.find('denver-deal-not-end')
      deal.fulfillment_method = "redemptioncoded"
      deal.should be_redemption_coded
    end

    it "not redemption deal" do
      deal =  Deal.find('denver-deal-not-end')
      deal.fulfillment_method = "not-redemptioncoded"
      deal.should_not be_redemption_coded
    end
  end

  describe "#printable?" do
    it "printable deal" do
      deal =  Deal.find('denver-deal-not-end')
      deal.fulfillment_method = "printed"
      deal.should be_printable
    end

    it "unprintable deal" do
      deal =  Deal.find('denver-deal-not-end')
      deal.fulfillment_method = "redmeptioncoded"
      deal.should_not be_printable
    end
  end

  describe "#sent_by_mail?" do
    it "shipped deal" do
      deal =  Deal.find('denver-deal-not-end')
      deal.fulfillment_method = "shipped"
      deal.should be_sent_by_mail
    end

    it "unshipped deal" do
      deal =  Deal.find('denver-deal-not-end')
      deal.fulfillment_method = "unshipped"
      deal.should_not be_sent_by_mail
    end
  end

  describe "#hide_addresses?" do
    it "never hide address" do
      Deal.find('denver-deal-not-end').hide_addresses?.should be_false
    end
  end

  describe "#location?" do
    it "always show false" do
      Deal.find('denver-deal-not-end').location?.should be_false
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
    let(:user) { user = User.find_by_email("1111@q.com").first }
    let(:deal) { Deal.find("denver-deal-not-end") }

    let(:purchase) do
      params = {:qty =>2, :confirm => true, :cardholder_name => "foo", :number =>"4013686575532315", :verification_value=> "123", :month => "02", :year=> "2015"}
      purchase = Purchase.create({
            :user_id => user.id,
            :deal_id => deal.id,
            :quantity => params[:qty],
            :confirm => params[:confirm],
            :credit_card_info => {
              :name => params[:cardholder_name],
              :number => params[:number],
              :verification_value => params[:verification_value],
              :month => params[:month],
              :year => params[:year]
            }
          })
    end

    before(:each) do
      purchase
    end

    context "#last_purchase" do
      specify {deal.last_purchase.should == purchase}
      specify {Deal.find("denver-deal-ended").last_purchase.should == nil}
    end

    context "last_purchase_for_user" do
      it "should be nil if no user" do
        deal.last_purchase_for_user(nil).should be nil
      end

      it "should be last_purchase for the user" do
        deal.last_purchase_for_user(user).should == purchase
      end
    end
  end

  describe "#externalpurchase_url?" do
    it "should show true when external_url is not blank" do
      deal =  Deal.find('denver-deal-external-url')
      deal.external_purchase_url?.should be true
    end

    it "should show false when external_url is not blank" do
      deal =  Deal.find('denver-deal-no-external-url')
      deal.external_purchase_url?.should be false
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

  describe "#max_purchasable_per_transaction" do
    before(:each) do
      Dupe.create :user, :id =>1, :email => "num_bought@q.com"
      Dupe.create :deal, :id => "number_bought", :region_id => 'denver' ,:title => "denver deal #D", :purchasable_number => 20, :max_per_user => 20, :inventory_limit => 20, :num_purchased => 10, :num_left => 10, :soldout => false
      Dupe.create :purchase, :user_id => 1, :deal_id => "number_bought", :num_bought => 5, :created_at => Time.now.to_s, :credits => 50, :price => 20, :payment_state => "charged", :confirm => true
    end

    it "should calculate display_max_purchasable" do
      user = User.find_by_email("num_bought@q.com").first
      deal = Deal.find('number_bought')
      deal.max_purchasable_per_transaction(user).should be 15
    end
  end

end
