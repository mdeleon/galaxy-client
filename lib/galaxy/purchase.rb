module Galaxy
  class Purchase < Galaxy::Base
    extend Timeify

    has_many   :coupons
    belongs_to :deal
    belongs_to :credit_card

    timeify :created_at

    def checkout
      put(:checkout)
    end

    def amount
      total
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