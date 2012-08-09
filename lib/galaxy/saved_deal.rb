module Galaxy
  class SavedDeal < Galaxy::Base
    timeify :created_at
    
    def deal
      @deal ||= model_for(:deal).find(self.deal_id)
    end
  end
end
