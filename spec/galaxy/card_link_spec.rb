require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/card_link"

describe Galaxy::CardLink do
  let(:cardlink_id) { "d9c3k19d" }
  let(:linked_cardlink)   { { :linked => true } }
  let(:unlinked_cardlink) { { :linked => false } }
  let(:cardlink) { Galaxy::CardLink.new(:id => cardlink_id) }

  describe "#link" do
    it "sends PUT to /card_links/:id/link.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink_id}/link.json", post_headers, linked_cardlink.to_json, 200)
      cl = cardlink.link
      cl.linked.should eq true
    end
  end

  describe "#unlink" do
    it "sends PUT to /card_links/:id/unlink.json" do
      mock_galaxy(:put, "/api/v2/card_links/#{cardlink_id}/unlink.json", post_headers, unlinked_cardlink.to_json, 200)
      cl = cardlink.unlink
      cl.linked.should eq false
    end
  end

  describe "#linked?" do
    context "when the state is linked" do
      it "should be linked" do
        subject.stub(:state).and_return('linked')
        expect(subject.linked?).to eq(true)
      end
    end

    context "when the state is not linked" do
      it "should not be linked" do
        subject.stub(:state).and_return('unlinked')
        expect(subject.linked?).to eq(false)
      end
    end
  end

  describe "#fulfilled?" do
    context "when the state is fulfilled" do
      it "is fullfiled" do
        subject.stub(:state).and_return("fulfilled")
        expect(subject).to be_fulfilled
      end
    end

    context "when the state is not fulfilled" do
      it "is not fulfilled" do
        subject.stub(:state).and_return("something else")
        expect(subject).not_to be_fulfilled
      end
    end
  end

  describe "#expired?" do
    context "deal is expired" do
      let(:deal) { double :deal, :expires_at => 1.day.ago }
      it "returns true if the offer was expired" do
        subject.stub(:deal).and_return deal
        expect(subject).to be_expired
      end
    end

    context "deal is active" do
      let(:deal) { double :deal, :expires_at => 1.day.from_now }
      it "returns false if the offer was active" do
        subject.stub(:deal).and_return deal
        expect(subject).not_to be_expired
      end
    end
  end

  describe "#self.create_or_relink_card_link" do
    let(:card_link)          { double(:card_link) }
    let(:card_link_linked)   { double(:link => card_link)}

    context "when cardlink exists" do
      it "should return the existing cardlink" do
        card_link_linked.should_receive(:link)
       expect( Galaxy::CardLink.create_or_relink(1, 1, card_link_linked)).to eq(card_link)
      end
    end
    context "when card link does not exist" do
      it "should return a new CardLink object" do
        Galaxy::CardLink.should_receive(:create).with({:user_id => 1,
                                               :deal_id => 1})
                                        .and_return { card_link_linked}
        card_link_linked.should_receive(:link).exactly(1).times
        expect(Galaxy::CardLink.create_or_relink(1, 1, nil)).to eq(card_link)
      end
    end
  end
end
