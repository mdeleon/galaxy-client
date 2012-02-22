module Galaxy
  class Purchase < Galaxy::Base
    has_many :coupons

    def checkout
      put(:checkout)
    end

    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end

    def credit_card
      @credit_card ||= model_for(:credit_card).find(self.credit_card_id)
    end
  end
end