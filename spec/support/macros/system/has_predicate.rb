module Macros
  module System
    def has_predicate(predicate_name)
      HasPredicateTest.new self, predicate_name
    end

    class HasPredicateTest
      attr_reader :example_group, :predicate_name
      attr_reader :field_name
      def initialize(example_group, predicate_name)
        @example_group = example_group
        @predicate_name = predicate_name
      end

      def by_field(field_name)
        @field_name = field_name
        self
      end

      def with_true_value_of(true_value)
        predicate_name = self.predicate_name
        field_name = self.field_name
        example_group.describe "##{predicate_name}" do
          context "when #{field_name} has #{true_value}" do
            before { subject.stub(field_name).and_return true_value }
            it { expect(subject.send(predicate_name)).to be_true }
          end
          context "when #{field_name} has #{true_value}" do
            before { subject.stub(field_name).and_return "#{true_value} - no" }
            it { expect(subject.send(predicate_name)).to be_false }
          end
        end
      end

      def based_on(method_name)
        predicate_name = self.predicate_name
        example_group.context "when #{method_name} returns nil" do
          it "returns false" do
            subject.stub(method_name).and_return nil
            subject.send(predicate_name, expect(*args)).to be_false
          end
        end

        example_group.context "when #{method_name} returns a non-nil value" do
          it "returns true" do
            subject.stub(method_name).and_return "something"
            subject.send(predicate_name, expect(*args)).to be_true
          end
        end
      end
    end
  end
end
