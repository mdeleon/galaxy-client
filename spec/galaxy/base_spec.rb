require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/base"

describe Galaxy::Base do
  class Galaxy::Model
    include Galaxy::Base
  end

  describe ".new" do
    it "assigns attributes" do
      model = Galaxy::Model.new(:key => :value)
      model.attributes.should == { "key" => :value }
    end

    it "provides indifferent access" do
      model = Galaxy::Model.new("key" => :value, :key2 => :value2)
      model.attributes[:key].should == :value
      model.attributes["key2"].should == :value2
    end
  end

  describe ".create" do
    it "succeeds" do
      stub_request(:post, /.*\/model.*/).to_return(fixture("model/create_valid.json"))

      sub = Galaxy::Model.create(:key => :value)
      sub.id.should be
    end

    it "succeeds for any 200 response code" do
      stub_request(:post, /.*\/model.*/).to_return(fixture("model/create_accepted.json"))

      sub = Galaxy::Model.create(:key => :value)
      sub.id.should be
    end

    it "raises a ValidationError on 422 response with errors" do
      stub_request(:post, /.*\/model.*/).to_return(fixture("model/create_invalid.json"))

      expect { Galaxy::Model.create(:key => '') }.to raise_error { |error|
        error.should be_a(Galaxy::ValidationError)
        error.errors.should == { "key" => ["is missing", "is invalid"] }
      }
    end

    it "raises a RuntimeError if attempting ot assign :id"
  end

  describe "#retrieve" do
    #     it "raises a NotFoundError on 404 response" do
    #       stub_request(:post, /.*\/model.*/).to_return(fixture("model/create_invalid.json"))

    #       expect { Galaxy::Model.create(:key => '') }.to raise_error { |error|
    #         error.should be_a(Galaxy::ValidationError)
    #         error.errors.should == { :key => ["is missing", "is invalid"] }
    #       }
    #     end
  end

  describe "#digest" do
    it "assigns attributes from response"
    it "underscores keys"
    it "provides indifferent access"
  end

  describe "#endpoint" do
    it "returns /models"
    it "returns parent_resource/id/models"
  end

  describe "#assert_response!" do
    it "succeeds"
    it "raises Galaxy::NotFoundError for response code 404"
    it "raises Galaxy::ValidationError for response code 422"
    it "raises Galaxy::InternalError for response code 500"
  end

  describe "#method_missing" do
    let(:model) { Galaxy::Model.new(:key => :value) }

    it "returns value for key" do
      model.key.should == :value
    end

    it "returns boolean for key" do
      model.key?.should == true
    end

    it "assigns value for key" do
      model.key = :value2
      model.key.should == :value2
    end
  end
end
