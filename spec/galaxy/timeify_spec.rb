require "spec_helper"

describe Timeify do
  let(:super_class) {
    Class.new do
      attr_accessor :created_at
      attr_accessor :updated_at, :other
    end
  }
  let(:klass) {
    Class.new(super_class) do
      extend Timeify
      timeify :created_at
    end
  }

  subject { klass.new }
  describe ".timeify" do
    let(:time_string) { "2012-09-08 13:21:11 UTC" }
    context "when the super.created_at is nil" do
      it "returns nil" do
        subject.created_at.should be_nil
      end
    end

    context "when the super.created_at is a time string" do
      it "returns the parsed time" do
        subject.created_at = time_string
        subject.created_at.should eq(Time.parse(time_string))
      end
    end

    context "when the super.created_at is a Time object" do
      it "return the time directly" do
        subject.created_at = Time.now
        subject.created_at.should be_a(Time)
      end
    end

    it "can take more than one fields" do
      klass.send :timeify, :updated_at, :other
      subject.updated_at = time_string
      subject.updated_at.should be_a(Time)
      subject.other = time_string
      subject.other.should be_a(Time)
    end
  end
end
