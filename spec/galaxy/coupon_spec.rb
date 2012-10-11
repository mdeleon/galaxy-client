require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/coupon"

describe Galaxy::Coupon do
  it_timeifies :expires_at
  has_predicate(:redeemed?).by_field(:state).with_true_value_of("redeemed")
  has_predicate(:active?).by_field(:state).with_true_value_of("valid")

  describe "#redeem" do
    it "sends PUT to /coupons/:id/redeem.json" do
      coupon = Galaxy::Coupon.new(:id => "d02k49d")
      mock_galaxy(:put, "/api/v2/coupons/#{coupon.id}/redeem.json", post_headers, nil, 200)
      coupon.redeem
    end
  end

  before(:each) do
    user = Dupe.find(:user)
    deal = Dupe.find(:deal)
    credit_card = Dupe.create :credit_card, :user_id => user.id
    purchase = Dupe.create :purchase, :deal_id => deal.id, :user_id => user.id, :credit_card_id => credit_card.id, :payment_state => 'charged'
    Dupe.create :coupon, :deal_id => deal.id, :purchase_id => purchase.id, :user_id => user.id, :credit_card_id => credit_card.id
  end

  let(:coupon) { User.find_by_email("1111@q.com").first.active_coupons.first}

  describe "#credit_card" do
    it "has credit card" do
      coupon.credit_card.should_not be_nil
    end

    it "doesn't have credit_card" do
      coupon.credit_card_id = nil
      coupon.credit_card.should == nil
    end
  end

  describe "#purchase" do
    it "find purchase by coupon.purchase_id" do
      coupon.purchase.should_not be_nil
    end
  end

  describe "#valid?" do
    it "valid" do
      coupon.valid?.should be_true
    end

    it "invalid" do
      coupon.state = nil
      coupon.valid?.should be_false
    end
  end

  describe "#expiring_soon?" do
    it "expiring soon" do
      coupon.should_receive(:expires_at).at_least(1).and_return 7.days.from_now
      coupon.expiring_soon?.should be_true
    end

    it "not valid" do
      coupon.should_receive(:valid?).and_return false
      coupon.expiring_soon?.should be_false
    end

    it "expired_at" do
      coupon.expiring_soon?.should be_false
    end

    it "state expired" do
      coupon.should_receive(:expired?).and_return true
      coupon.expiring_soon?.should be_false
    end
  end

  describe "#inactive?" do
    it "cancelled" do
      coupon.stub!(:state).and_return "cancelled"
      coupon.inactive?.should be_true
    end

    it "expired" do
      coupon.stub!(:state).and_return "expired"
      coupon.inactive?.should be_true
    end

    it "active" do
      coupon.stub!(:state).and_return "valid"
      coupon.inactive?.should be_false
    end

    it "redeemed" do
      coupon.stub!(:state).and_return "redeemed"
      coupon.inactive?.should be_true
    end

    it "reissued" do
      coupon.stub!(:state).and_return "reissued"
      coupon.inactive?.should be_false
    end
  end

  describe "#active?" do
    it "cancelled" do
      coupon.stub!(:state).and_return "cancelled"
      coupon.active?.should be_false
    end

    it "active" do
      coupon.stub!(:state).and_return "valid"
      coupon.active?.should be_true
    end

    it "expired" do
      coupon.stub!(:state).and_return "expired"
      coupon.active?.should be_false
    end

    it "redeemed" do
      coupon.stub!(:state).and_return "redeemed"
      coupon.active?.should be_false
    end

    it "reissued" do
      coupon.stub!(:state).and_return "reissued"
      coupon.active?.should be_true
    end
  end

  describe "#expiry(timezone)" do
    it "return time in specific timezone" do
      coupon.expiry("Hawaii").zone.should == "HST"
    end
  end

  describe "#expired?" do
    shared_examples "expired by state" do
      context "when the state is 'expired'" do
        it "returns true" do
          subject.stub(:state).and_return "expired"
          expect(subject).to be_expired
        end
      end
      context "when the state is not 'expired'" do
        it "returns true" do
          subject.stub(:state).and_return "non-expired"
          expect(subject).not_to be_expired
        end
      end
    end

    context "when the expires_at is nil" do
      include_examples "expired by state"
    end

    context "when the expires_at is in the future" do
      include_examples "expired by state"
    end

    context "when the expires_at is in the past" do
      before(:each) do
        subject.stub(:expires_at).and_return 1.minute.ago
      end

      it "doesn't ask its state for determination" do
        subject.should_not_receive(:state)
        subject.expired?
      end

      it "is expired" do
        expect(subject).to be_expired
      end
    end
  end

  describe "#printable?" do
    it "is printable" do
      coupon.stub!(:state).and_return "valid"
      coupon.printable?.should be_true
    end
    it "is not printable if coupon is not active" do
      coupon.stub!(:state).and_return "cancelled"
      coupon.printable?.should be_false
    end
    it "is not printable if payment is not charged" do
      coupon.stub!(:state).and_return "valid"
      p = coupon.purchase
      p.stub!(:payment_state).and_return "declined"
      coupon.stub!(:purchase).and_return p
      coupon.printable?.should be_false
    end

     it "is printable if deal is redemption coded" do
      coupon.stub!(:state).and_return "valid"
      d = coupon.deal
      p = coupon.purchase
      p.stub!(:deal).and_return d
      d.stub!(:fulfillment_method).and_return "redemptioncoded"
      coupon.stub!(:purchase).and_return p
      coupon.stub!(:deal).and_return d
      coupon.printable?.should be_true
    end
  end
end
