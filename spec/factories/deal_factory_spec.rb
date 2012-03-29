require File.join(File.basename(__FILE__), "../spec_helper.rb")

describe "Deal Factory" do

  shared_examples "a deal factory" do
    it "should should create a deal" do
      assert { subject }
    end

    it "should should generate a merchant_id" do
      assert { !subject.merchant_id.nil? }
    end

    it "should should generate a merchant_name" do
      assert { !subject.merchant_name.nil? }
    end
  end

  context "vanilla factory" do
    subject { Factory(:deal) }
    it_behaves_like "a deal factory"
  end

  context "factory given a merchant with a name" do
    let(:merchant) { Factory(:merchant, :name => 'merchant_name', :id => 'merchant_id') }
    subject { Factory(:deal, :merchant => merchant) }
    it_behaves_like "a deal factory"
  end
end
