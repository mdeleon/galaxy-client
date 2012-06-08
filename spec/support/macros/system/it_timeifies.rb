module Macros
  module System
    def it_timeifies(*fields)
      fields.each do |field|
        describe "##{field}" do
          [Time.now, "2012-09-18 11:23:56 UTC"].each do |time|
            let(:time) { time }
            it "returns a Time object" do
              subject.send("#{field}=", time)
              subject.send(field).should be_a(Time)
            end
          end
          it "return nil if super is nil" do
            subject.send(field).should be_nil
          end
        end
      end
    end
  end
end
