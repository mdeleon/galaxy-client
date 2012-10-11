require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/category"

require 'spec_helper'

describe Galaxy::Category do
  describe ".sorted_list" do
    let(:h) { double :h, :name => "H" }
    let(:b) { double :b, :name => "B" }
    let(:d) { double :d, :name => "D" }
    let(:non_existent) { double :non_existent, :name => "Non Existent" }
    let(:categories) { [ d, h, b] }

    before(:each) do
      Category.stub(:category_for_display).and_return(%W(H C B A D T))
    end

    it "doesn't returns the category that not in the category_for_display list" do
      Category.stub(:all).and_return [b, non_existent]
      expect(Category.sorted_list).not_to include(non_existent)
    end

    it "returns list sorted by category_for_display order" do
      Category.stub(:all).and_return categories
      expect(Category.sorted_list).to eq([h, b, d])
    end
  end
end
