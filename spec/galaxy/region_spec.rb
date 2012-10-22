require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/region"

describe Galaxy::Region do
  has_predicate(:national?).by_field(:id).with_true_value_of("united-states")

  describe "#current_deal" do
    it "sends GET to /regions/:id/current_deal.json" do
      deal = { :deal => { :id => "d9c3k19d" }}
      region = Galaxy::Region.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/regions/#{region.id}/current_deal.json", get_headers, deal.to_json, 200)

      current_deal = region.current_deal
      current_deal.should be_instance_of(Galaxy::Deal)
      current_deal.id.should == "d9c3k19d"
    end
  end

  describe ".national" do
    it "returns the national region" do
      Galaxy::Region.should_receive(:find).with("united-states").and_return subject
      expect(Galaxy::Region.national).to eq(subject)
    end
  end

  describe "#national?" do
    context "a national region" do
      subject { Galaxy::Region.new(:id => "united-states")}
      it { should be_national }
    end

    context "a not_national region" do
      subject { Galaxy::Region.new(:id => "denver")}
      it { should_not be_national }
    end
  end

  describe ".all" do
    let(:selectable_region) { double :region, :selectable? => true }
    let(:unselectable_region) { double :region, :selectable? => false }

    before do
      Galaxy::Base.stub(:all).and_return([selectable_region, unselectable_region])
    end

    it "returns all regions are selectable" do
      expect(Galaxy::Region.all).to eq([selectable_region])
    end
  end

  describe "#deals" do
    it "sends GET to /regions/:id/deals.json" do
      deals = [{ :id => "d9c3k19d" }]
      region = Galaxy::Region.new(:id => "d02k49d")
      mock_galaxy(:get, "/api/v2/regions/#{region.id}/deals.json", get_headers, deals.to_json, 200)

      region = Galaxy::Region.new(:id => region.id)
      response = region.deals
      response.should be_instance_of(Array)
      response.first.should be_instance_of(Galaxy::Deal)
      response.first.id.should ==  "d9c3k19d"
    end
  end

  describe "#from_ip" do
    let(:region_json) {"{\"active\":true,\"slug\":\"san-francisco\",\"name\":\"San Francisco\",\"id\":\"san-francisco\"}"}

    it "sends GET to /regions/from_ip.json" do
      mock_galaxy(:get, "/api/v2/regions/from_ip.json?ip=127.0.0.1", get_headers, region_json, 200)
      response = Galaxy::Region.from_ip('127.0.0.1')
    end

    it "parses json into a region object" do
      response = Galaxy::Region.from_ip('127.0.0.1')
      response.should be_instance_of(Galaxy::Region)
      response.id.should ==  "san-francisco"
    end
  end

  describe ".active_from_ip" do
    it 'should call from_ip' do
      subject.stub(:active => true, :id => 'LOL')
      Galaxy::Region.should_receive(:from_ip).and_return(subject)
      results = Galaxy::Region.active_from_ip('13123123')
      expect(results.id).to eq(subject.id)
    end
  end

  describe '#active?' do
    it 'is true when active is true' do
      subject.stub(:active => true)
      expect(subject).to be_active
      subject.stub(:active => false)
      expect(subject).to_not be_active
    end
  end

  describe '#selectable' do
    it 'must be selectable and active to really be selectable'
  end

  describe '.national_region_id' do
    specify { Galaxy::Region.national_region_id.should eq('united-states') }
  end

  describe ".by_id_or_nil" do
    context "when a region is found by the id" do
      before(:each) do
        Galaxy::Region.stub(:find).and_return subject
      end
      it "returns it" do
        expect(Galaxy::Region.by_id_or_nil(123)).to eq(subject)
      end
    end

    context "when a region is not found by the id" do
      before(:each) do
        Galaxy::Region.stub(:find).and_raise(
          ActiveResource::ResourceNotFound.new("nf")
        )
      end
      it "returns nil" do
        expect(Galaxy::Region.by_id_or_nil(123)).to be_nil
      end
    end
  end

end
