module Galaxy
  class Coupon < Galaxy::Base
    def redeem
      put(:redeem)
    end
  end
end
