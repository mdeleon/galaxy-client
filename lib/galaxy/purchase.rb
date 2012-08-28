module Galaxy
  class Purchase < Galaxy::Base
    has_many :coupons

    alias :amount :total

    def checkout
      put(:checkout)
    end

    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end

    def credit_card
      @credit_card ||= model_for(:credit_card).find(self.credit_card_id)
    end

    def charged?
      payment_state == 'charged'
    end

    def valid_coupons
      self.coupons.select{ |coupon| coupon.state == 'valid'}
    end

    def printable?
      !!(charged? and deal.printable?)
    end
  end
end