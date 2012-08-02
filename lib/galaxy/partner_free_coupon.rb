module Galaxy
  class PartnerFreeCoupon < Galaxy::Base
    def self.fetch_all(params)
      find :all, from: "#{self.site}deals/#{params[:deal_id]}/partner_free_coupons.json"
    end
  end
end
