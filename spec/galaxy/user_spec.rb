require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/user"

describe Galaxy::User do
  subject {Galaxy::User.new(user_hash.merge(:last_login_at => nil))}
  it_timeifies :last_login_at

  let(:user_hash) { { id: "ABC123", email: "test@test.com", :created_at => nil, postal_code: "94110",
    :lastname => "bar", firstname: "foo", credits: 0, share_link: "whatevers" } }
  let(:users_ary) { { :users => [user_hash] } }
  let(:http_ok)   { { :status => 'success' } }

  it_timeifies :created_at, :last_login_at

  describe ".find_external_admin_by_email" do
    let(:user) { double :user }
    let(:result) { Galaxy::User.find_external_admin_by_email("e@example.com").first }
    it "gets the /users/find_external_admin_by_email.json" do
      Galaxy::User.should_receive(:get).with(
        :find_external_admin_by_email,
        :email => "e@example.com"
      ).and_return [ {:attr => "val"} ]
      result.attr.should eq("val")
    end

    context "when a ResourceNotFound is raised" do
      it "returns an empty array" do
        Galaxy::User.stub(:get).and_raise(ActiveResource::ResourceNotFound.new(user))
        Galaxy::User.find_external_admin_by_email("e@example.com").should be_empty
      end
    end
  end

  describe ".find_by_token" do
    it "sends GET to /users/find_by_token.json" do
      mock_galaxy(:get, "/api/v2/users/find_by_token.json?token=123", get_headers, users_ary.to_json, 200)
      Galaxy::User.find_by_token("123").first.id.should eql "ABC123"
    end
  end

  describe ".find_by_email" do
    it "sends GET to /users/find_by_email.json" do
      mock_galaxy(:get, "/api/v2/users/find_by_email.json?email=test%40test.com", get_headers, users_ary.to_json, 200)
      Galaxy::User.find_by_email("test@test.com").first.id.should eql "ABC123"
    end
  end

  describe "#full_name" do
    context "user with a full_name" do
      it "should get the full_name" do
        subject.full_name.should == "foo bar"
      end
    end

    context "user without a full_name" do
      it "should return void without a full_name" do
        subject.firstname = subject.lastname = nil
        subject.full_name.should == ""
      end
    end
  end

  describe "#has_firstname?" do
    it "should return false if the user has not a firstname" do
      subject.firstname = nil
      subject.has_firstname?.should be_false
    end

    it "sould return false if the user's firstname is blank string " do
      subject.firstname =""
      subject.has_firstname?.should be_false
    end

    it "should return true if the user has a firstanme" do
      subject.has_firstname?.should be_true
    end
  end

  describe "#has_lastname?" do
    it "should return false if the user has not a lastname" do
      subject.lastname = nil
      subject.has_lastname?.should be_false
    end

    it "sould return false if the user's lastname is blank string " do
      subject.lastname = ''
      subject.has_lastname?.should be_false
    end

    it "should return true if the user has a lastname" do
      subject.lastname = 'test'
      subject.has_lastname?.should be_true
    end
  end

  describe "#save_deal" do
    let(:saved_deal) { double :saved_deal, :deal_id => 234}
    before(:each) do
      subject.stub(:saved_deals).and_return([saved_deal])
    end

    context "when the deal has already been saved" do
      it "doesn't create a new saved_deal" do
        Galaxy::SavedDeal.should_not_receive(:create)
        subject.save_deal 234
      end
    end

    context "when the deal is not saved" do
      it "create a new saved_deal" do
        subject.stub(:id => 567)
        Galaxy::SavedDeal.should_receive(:create).with(
          :user_id => 567,
          :deal_id => 235
        )
        subject.save_deal 235
      end
    end
  end


  describe '#daily_deal_coupons' do
    let(:coupon_daily_deal) { double :coupon, :deal_id => 1 }
    let(:coupon_card_link) { double :coupon, :deal_id => 2}
    let(:card_link) { double :card_link, :deal_id => 2}

    it 'should be able to filter out only coupons that point to daily-deals' do
      subject.stub(:coupons).and_return([coupon_daily_deal, coupon_card_link])
      subject.stub(:card_links).and_return([card_link])
      expect(subject.daily_deal_coupons.map(&:deal_id)).to eq([1])
    end
  end

  describe "#unlink_deal" do
    let(:card_link) {double :card_link, :deal_id => 134 }
    before(:each) { subject.stub(:card_links).and_return [card_link] }

    context "when a card_link is found for the deal" do
      it "unlinks it" do
        card_link.should_receive(:unlink)
        subject.unlink_deal 134
      end
    end

    context "when no card_link is found for the deal" do
      it "return nil" do
        expect(subject.unlink_deal(123)).to be_nil
      end
    end
  end


  describe "#category_active_for?" do
    let(:category_preference) { double :category_preference,
                                       :category_id => 12 }

    context "when the category_preferences is blank" do
      it "returns nil" do
        subject.stub(:category_preferences).and_return nil
        expect(subject.category_active_for?(:whatever)).to be_false
      end
    end

    context "when the category_preferences is not blank" do
      before(:each) do
        subject.stub(:category_preferences).and_return [category_preference]
      end

      context "and the category_id matches" do
        it "returns true" do
          expect(subject.category_active_for?(double(:category, :id => 12))).to be_true
        end
      end

      context "and the category_id doesn't matches" do
        it "returns false" do
          expect(subject.category_active_for?(double(:category, :id => 13))).to be_false
        end
      end
    end
  end

  describe "#unsave_deal" do
    let(:saved_deal) { double :saved_deal, :deal_id => 234, :destroy => true }
    before(:each) do
      subject.stub(:saved_deals).and_return([saved_deal])
    end

    context "when the deal is saved" do
      it "destroy it" do
        saved_deal.should_receive(:destroy)
        subject.unsave_deal 234
      end
    end

    context "when the deal is not saved" do
      it "does nothing" do
        saved_deal.should_not_receive(:destroy)
        subject.unsave_deal 235
      end
    end
  end


  describe "#fulfilled_deal?" do
    context "it's an offer" do
      let(:deal) { double(:deal, :id => 1, :card_linked? => true) }
      let(:unfulfilled_card_link)    { double(:card_link, :deal_id => deal.id, :fulfilled? => false) }
      let(:fulfilled_card_link) { double(:card_link, :deal_id => deal.id, :fulfilled? => true) }

      it "should return true for a fulfilled offer" do
        subject.stub(:card_links).and_return([fulfilled_card_link])
        expect(subject.fulfilled_deal?(deal)).to be_true
      end

      it "should return false for a unfulfilled offer" do
        subject.stub(:card_links).and_return([unfulfilled_card_link])
        expect(subject.fulfilled_deal?(deal)).to be_false
      end
    end

    context "it's an daily deal" do
      let(:deal) { double(:deal, :id => 1, :card_linked? => false) }
      let(:unredeemed_coupon)    { double(:coupon, :deal_id => deal.id, :redeemed? => false) }
      let(:redeemed_coupon) { double(:coupon, :deal_id => deal.id, :redeemed? => true) }

      it "should return true for a redeemed coupon" do
        subject.stub(:coupons).and_return([redeemed_coupon])
        expect(subject.fulfilled_deal?(deal)).to be_true
      end

      it "should return false for a unredeemed coupon" do
        subject.stub(:coupons).and_return([unredeemed_coupon])
        expect(subject.fulfilled_deal?(deal)).to be_false
      end
    end
  end

  describe "#relink_deal" do
    let(:deal) { mock(:id => 1, :merchant => 'some merchant') }
    let(:card_links) do
      [mock('a card link', :linked? => true), mock('other card link', :linked? => false)]
    end

    it "unlinks linked deals for that merchant and links the deal" do
      subject.stub(:card_links_for_merchant).with(deal.merchant)
      .and_return(card_links)
      card_links.first.should_receive(:unlink)
      subject.should_receive(:link_deal).with(deal.id)
      subject.relink_deal(deal)
    end
  end

  describe "#link_deal" do
    let(:card_link) { double(:card_link, :link => double('cl'))}
    let(:card_link_linked)   { double(:card_link,
                                      :deal_id => 11,
                                      :state => 'linked',
                                      :link => card_link,
                                      :linked? => true)}
    let(:card_link_unlinked) { double(:card_link,
                                      :deal_id => 22,
                                      :state => 'unlinked',
                                      :link => card_link,
                                      :linked? => false)}
    let(:card_links) { [card_link_linked, card_link_unlinked] }

    before do
      subject.stub(:id).and_return(123)
      subject.stub(:current_user) { double(:offers_enabled? => true)}
    end

    context "when the cardlink already exists and is already linked" do
      let(:card_link)   { double(:card_link,
                                 :deal_id => 11,
                                 :state => 'linked',
                                 :linked? => true) }
      it "return linked_already" do
        subject.stub(:card_links).and_return [card_link]
        expect(subject.link_deal(11)).to eq('linked_already')
      end
    end

    context "when cardlink has not been created and not linked" do
      before do
        subject.stub(:card_links).and_return []
        Galaxy::CardLink.stub(:create_or_relink)
        subject.stub(:reload)
        subject.stub(:unsave_deal)
      end

      it "create a card_link" do
        Galaxy::CardLink.should_receive(:create_or_relink)
        subject.link_deal(1)
      end

      it "reload the user" do
        subject.should_receive(:reload)
        subject.link_deal(1)
      end

      it "unsave the offer" do
        subject.should_receive(:unsave_deal)
        subject.link_deal(1)
      end
    end
  end

  describe "#has_purchased?" do
    context "it's an offer" do
      let(:deal) { double(:deal, :id => 1, :card_linked? => true) }
      let(:linked_card_link)    { double(:card_link, :deal_id => deal.id, :state => "linked") }
      let(:unlinked_card_link) { double(:card_link, :deal_id => deal.id, :state => "unlinked") }

      it "should return true for a linked offer" do
        subject.stub(:card_links).and_return([linked_card_link])
        expect(subject.has_purchased?(deal)).to be_true
      end

      it "should return false for a unlinked offer" do
        subject.stub(:card_links).and_return([unlinked_card_link])
        expect(subject.has_purchased?(deal)).to be_false
      end
    end

    context "it's an daily deal" do
      let(:deal) { double(:deal, :id => 1, :card_linked? => false) }
      let(:cancelled_coupon)    { double(:coupon, :deal_id => deal.id, :state => "cancelled") }
      let(:uncancelled_coupon) { double(:coupon, :deal_id => deal.id, :state => "valid") }

      it "should return true for a uncancelled coupon" do
        subject.stub(:coupons).and_return([uncancelled_coupon])
        expect(subject.has_purchased?(deal)).to be_true
      end

      it "should return false for a unredeemed coupon" do
        subject.stub(:coupons).and_return([cancelled_coupon])
        expect(subject.has_purchased?(deal)).to be_false
      end
    end
  end

  describe "#card_linked?" do
    let(:card_link) {double :card_link, :deal_id => 134 }
    let(:deal) { double :deal, :id => 123 }
    before(:each) { subject.stub(:card_links).and_return [card_link] }

    context "when no card_link is found for the deal" do
      it "returns false" do
        expect(subject.card_linked?(deal)).to be_false
      end
    end

    context "when a card_link is found for the deal" do
      before(:each) do
        deal.stub(:id).and_return 134
      end

      context "and the card_link is not linked" do
        it "returns false" do
          card_link.stub(:linked?).and_return false
          expect(subject.card_linked?(deal)).to be_false
        end
      end

      context "and the card_link is linked" do
        it "returns true" do
          card_link.stub(:linked?).and_return true
          expect(subject.card_linked?(deal)).to be_true
        end
      end
    end
  end

  describe "#is_saved?" do
    let(:deal) { double :deal, :id => 123 }
    let(:saved_deal) { double :saved_deal, :deal_id => 124 }

    before(:each) { subject.stub(:saved_deals).and_return [saved_deal] }

    context "when a saved_deal is found for the deal" do
      it "return true" do
        deal.stub(:id).and_return 124
        expect(subject.is_saved?(deal)).to be_true
      end
    end

    context "when no saved_deal is found for the deal" do
      it "return false" do
        expect(subject.is_saved?(deal)).to be_false
      end
    end
  end

  describe "#card_links_for_merchant" do
    let(:merchant) { double(:id => 1) }

    it "returns card links by merchant" do
      card_links = 2.times.map { stub(:merchant_id => 1) }
      subject.stub(:card_links).and_return(card_links)
      expect(subject.card_links_for_merchant(merchant)).to eq(card_links)
    end

    it "returns an empty array if the user no card links for the merchant" do
      card_link = stub(:merchant_id => 3)
      subject.stub(:card_links).and_return([card_link])
      expect(subject.card_links_for_merchant(merchant)).to eq([])
    end

    it "returns an empty array if the user has no card links at all" do
      subject.stub(:card_links).and_return([])
      expect(subject.card_links_for_merchant(merchant)).to eq([])
    end
  end
end
