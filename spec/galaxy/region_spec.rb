require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/region"

describe Galaxy::Region do
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
      Region.should_receive(:find).with("united-states").and_return subject
      expect(Region.national).to eq(subject)
    end
  end

  describe "#national?" do
    context "a national region" do
      subject { Region.new(:id => "united-states")}
      it { should be_national }
    end

    context "a not_national region" do
      subject { Region.new(:id => "denver")}
      it { should_not be_national }
    end
  end

  describe ".all" do
    let(:selectable_region) { double :region, :selectable? => true }
    let(:unselectable_region) { double :region, :selectable? => false }

    before do
      Galaxy::Region.stub(:all).and_return([selectable_region, unselectable_region])
    end

    it "returns all regions are selectable" do
      expect(Region.all).to eq([selectable_region])
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
    let(:subject) { Region.new }
    let(:ip) { "123.4.5.6" }

    context "when a region is found" do
      before(:each) do
        Region.stub(:from_ip).and_return subject
      end

      context "but it's not active" do
        before(:each) { subject.active = false }

        it "returns nil" do
          expect(Region.active_from_ip(ip)).to be_nil
        end
      end

      context "and it is active" do
        before(:each) { subject.active = true }

        it "returns the region" do
          expect(Region.active_from_ip(ip)).to eq(subject)
        end
      end
    end

    context "when the region is not found from the ip" do
      before(:each) do
        Region.stub(:from_ip).and_raise(
          ActiveResource::ResourceNotFound.new("nf")
        )
      end

      it "returns nil" do
        expect(Region.active_from_ip(ip)).to be_nil
      end
    end
  end

  describe '.from_ip' do
    it 'given ip can not be located' do
      Region.from_ip("127.0.0.1").should == Region.find('united-states')
    end

    it 'given ip can be located' do
      Region.from_ip("12.175.177.0").should == Region.find("los-angeles")
    end

    context "when galaxy client return an error" do
      it "return united-states" do
        Galaxy::Region.stub(:from_ip).and_raise ActiveResource::ResourceNotFound.new(1)
        Region.from_ip("1.2.3.4").should == Region.find('united-states')
      end
    end
  end

  describe '#active?' do
    specify { Region.find("denver").active?.should == true }
  end

  describe '#selectable' do
    specify { Region.find("denver").selectable.should == true }
  end

  describe '.selectable_regions' do
    specify { Region.selectable_regions.should == Region.find(:all) }
  end

  describe '.national_region_id' do
    specify {Region.national_region_id.should eq('united-states')}
  end

  describe ".by_id_or_nil" do
    context "when a region is found by the id" do
      before(:each) do
        Region.stub(:find).and_return subject
      end
      it "returns it" do
        expect(Region.by_id_or_nil(123)).to eq(subject)
      end
    end

    context "when a region is not found by the id" do
      before(:each) do
        Region.stub(:find).and_raise(
          ActiveResource::ResourceNotFound.new("nf")
        )
      end
      it "returns nil" do
        expect(Region.by_id_or_nil(123)).to be_nil
      end
    end
  end

end
