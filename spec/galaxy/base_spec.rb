require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/base"

describe Galaxy::Base do
  class Galaxy::Model < Galaxy::Base
  end

  it "includes root in json" do
    Galaxy::Model.include_root_in_json.should be
  end

  it "format is json" do
    Galaxy::Model.format.should == ActiveResource::Formats::JsonFormat
  end
end
