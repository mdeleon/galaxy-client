module Galaxy
  class Coupon < Galaxy::Base
    timeify :created_at, :redeemed_at, :expires_at
    
    def redeem(params={})
      begin
        put(:redeem, params)
      rescue ActiveResource::ResourceInvalid => e
        instance = self.class.new(params)
        instance.load_remote_errors(e)
        raise ActiveResource::ResourceInvalid.new(instance)
      end
    end

    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end

    def self.find_by_barcode(barcode)
      find(:all, from: "/api/v2/coupons/find_by_barcode.json", params: {:barcode => barcode})
    end
  end
end