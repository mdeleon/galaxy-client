module Galaxy
  class Coupon < Galaxy::Base
    def redeem
      put(:redeem)
    end

    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end
  end
end
