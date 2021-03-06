module Galaxy
  module Merchants
    class DealSummary < Galaxy::Base
      class << self
        def summary(params)
          find :one, from: raw_with_prefix("merchants/#{params[:merchant_id]}/deal_summaries.json")
        end
      end
    end
  end
end
