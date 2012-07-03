module Galaxy
  class Coupon < Galaxy::Base
    def redeem(params={})
      put(:redeem, params)
    end

    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end

    def self.find_by_barcode(barcode)
      find(:all, from: "/api/v2/coupons/find_by_barcode.json", params: {:barcode => barcode})
    end
  end
end