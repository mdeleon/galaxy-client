require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/coupon"

describe Galaxy::Coupon do

  subject {
    Galaxy::Coupon.new(:expires_at => nil,
    :created_at => nil,
    :redeemed_at => nil,
    :state => nil)
  }

  it_timeifies :expires_at, :created_at, :redeemed_at

  has_predicate(:redeemed?).by_field(:state).with_true_value_of("redeemed")
  has_predicate(:valid?).by_field(:state).with_true_value_of("valid")
  has_predicate(:cancelled?).by_field(:state).with_true_value_of("cancelled")

  describe "#redeem" do
    it "sends PUT to /coupons/:id/redeem.json" do
      mock_galaxy(:put, "/api/v2/coupons/#{subject.id}/redeem.json", post_headers, nil, 200)
      subject.redeem.code.should eq(200)
    end
  end

  describe "#has_expiration_date?" do
    context "has expires_at" do
      it "returns true" do
        subject.expires_at = Time.now + 1.week
        expect(subject.has_expiration_date?).to be_true
      end
    end
    context "has no expires_at" do
      it "returns false" do
        subject.expires_at = nil
        expect(subject.has_expiration_date?).to be_false
      end
    end
  end

  describe "#expiring_soon?" do
    before {
      subject.stub(:valid? => true)
      subject.stub(:expired? => false)
    }

    it "expiring soon" do
      subject.should_receive(:expires_at).at_least(1).and_return 7.days.from_now
      subject.expiring_soon?.should be_true
    end

    it "not valid" do
      subject.should_receive(:valid?).and_return false
      subject.expiring_soon?.should be_false
    end

    it "expired_at" do
      subject.expiring_soon?.should be_false
    end

    it "state expired" do
      subject.should_receive(:expired?).and_return true
      subject.expiring_soon?.should be_false
    end
  end

  describe "#inactive?" do
    it "cancelled" do
      subject.stub!(:state).and_return "cancelled"
      subject.inactive?.should be_true
    end

    it "expired" do
      subject.stub!(:state).and_return "expired"
      subject.inactive?.should be_true
    end

    it "active" do
      subject.stub!(:state).and_return "valid"
      subject.inactive?.should be_false
    end

    it "redeemed" do
      subject.stub!(:state).and_return "redeemed"
      subject.inactive?.should be_true
    end

    it "reissued" do
      subject.stub!(:state).and_return "reissued"
      subject.inactive?.should be_false
    end
  end

  describe "#active?" do
    it "cancelled" do
      subject.stub!(:state).and_return "cancelled"
      subject.active?.should be_false
    end

    it "expired" do
      subject.stub!(:state).and_return "expired"
      subject.active?.should be_false
    end

    it "redeemed" do
      subject.stub!(:state).and_return "redeemed"
      subject.active?.should be_false
    end

    it "reissued" do
      subject.stub!(:state).and_return "reissued"
      subject.active?.should be_true
    end
  end

  describe "#expiry(timezone)" do
    it "return time in specific timezone" do
      subject.expires_at = Time.now
      subject.expiry("Hawaii").zone.should == "HST"
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
        subject.stub(:state => 'valid')
        subject.stub(:expires_at).and_return 2.days.ago
      end

      it "is expired" do
        expect(subject).to be_expired
      end
    end
  end

  describe "#printable?" do
    it 'is not printable if purchse is not printable' do
      subject.stub_chain(:purchase, :printable?).and_return false
      subject.printable?.should be_false
    end

    context 'purchase is printable' do
      before {subject.stub_chain(:purchase, :printable?).and_return(true)}
      it "is printable" do
        subject.stub!(:state).and_return "valid"
        subject.printable?.should be_true
      end
      it "is not printable if coupon is not active" do
        subject.stub!(:state).and_return "cancelled"
        subject.printable?.should be_false
      end
    end
  end
end
