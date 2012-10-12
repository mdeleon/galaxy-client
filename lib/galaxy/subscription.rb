module Galaxy
  class Subscription < Galaxy::Base
    timeify :created_at
    
    def regional?
      self.region_id != "united-states"
    end

    def subscribe
      put(:subscribe)
    end

    def unsubscribe
      put(:unsubscribe)
    end

    def pause
      put(:pause)
    end
  end
end
