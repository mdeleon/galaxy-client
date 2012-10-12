require "spec_helper"

module Galaxy
  module Merchants
    describe DealSummary do
      describe ".summary" do
        it "finds the singleton resource" do
          DealSummary.should_receive(:find).with(
            :one, from: "/#{Galaxy::Base.path}/merchants/merchant-id/deal_summaries.json"
          )
          DealSummary.summary(merchant_id: "merchant-id")
        end
      end
    end
  end
end
