module Galaxy
  class Purchase < Galaxy::Base
    def checkout
      put(:checkout)
    end

    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end
  end
end