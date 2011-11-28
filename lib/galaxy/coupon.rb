module Galaxy
  class Coupon < Galaxy::Base
    def redeem
      put(:redeem)
    end

    def deal
      @deal ||= Galaxy::Deal.find(self.deal_id)
    end
  end
end
