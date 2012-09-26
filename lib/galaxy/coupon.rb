module Galaxy
  class Coupon < Galaxy::Base

    has_one :credit_card
    has_one :purchase
    has_one :deal

    def redeem(params={})
      begin
        put(:redeem, params)
      rescue ActiveResource::ResourceInvalid => e
        instance = self.class.new(params)
        instance.load_remote_errors(e)
        raise ActiveResource::ResourceInvalid.new(instance)
      end
    end

    def phone
      @phone ||= purchase.phone
    end

    def address
      @address ||= purchase.location
    end

    def self.find_by_barcode(barcode)
      find(:all, from: "/api/v2/coupons/find_by_barcode.json", params: {:barcode => barcode})
    end

    def expires_at
      super ? Time.parse(super) : nil
    end

    def expiry(timezone)
      expires_at ? expires_at.in_time_zone(timezone) : nil
    end

    def expired?
      state == 'expired' or (valid? and expires_at and expires_at.to_date.end_of_day < Time.now)
    end

    def valid?
      state == 'valid'
    end

    def inactive?
      !active?
    end

    def cancelled?
      self.state == 'cancelled'
    end

    def active?
      !cancelled? && !redeemed? && !expired?
    end

    def redeemed?
      self.state == 'redeemed'
    end

    def deal_shareable?
      active?
    end

    def printable?
      !!(purchase.printable? and !redeemed? and !cancelled?)
    end
  end
end