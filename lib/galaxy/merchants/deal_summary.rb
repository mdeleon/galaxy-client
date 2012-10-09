module Galaxy
  module Merchants
    class DealSummary < Galaxy::Base
      class << self
        def summary(params)
          #due to the implementation of ActiveResource::Base#find_one, path is necessary
          find :one, from: "/#{path}/merchants/#{params[:merchant_id]}/deal_summaries.json"
        end
      end
    end
  end
end
