require "spec_helper"

module Galaxy
  describe PartnerFreeCoupon do
    describe ".fetch_all" do
      it "finds all coupons" do
        PartnerFreeCoupon.should_receive(:find).with(
          :all, from: "#{Galaxy::Base.prefix}deals/deal-id/partner_free_coupons.json"
        )
        PartnerFreeCoupon.fetch_all(deal_id: "deal-id")
      end
    end
  end
end
