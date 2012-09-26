module Galaxy
  class Purchase < Galaxy::Base
    has_many :coupons

    alias :amount :total

    def checkout
      put(:checkout)
    end

    def deal
      @deal ||= if self.respond_to?(:deal)
        model_for(:deal).find(self.deal_id)
      else
        model_for(:deal).new(self.deal)
      end
    end

    def credit_card
      @credit_card ||= if self.respond_to?(:credit_card)
        model_for(:credit_card).find(self.credit_card_id)
      else
        model_for(:credit_card).new(self.credit_card)
      end
    end

    def active?
      payment_state == "active"
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