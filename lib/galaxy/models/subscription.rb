module Galaxy
  class Subscription < Galaxy::Base
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
