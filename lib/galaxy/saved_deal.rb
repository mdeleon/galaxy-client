module Galaxy
  class SavedDeal < Galaxy::Base
    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end
  end
end
