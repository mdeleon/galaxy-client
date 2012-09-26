module Galaxy
  class Subscription < Galaxy::Base

    has_one :user

    def regional?
      !national?
    end

    def national?
      region_id == 'united-states'
    end

    def has_region?
      respond_to?(:region_id) && region_id.present?
    end

    def subscribe
      put(:subscribe)
    end

    def unsubscribe
      put(:unsubscribe)
    end

    def active?
      self.status == "active"
    end

    def pause
      put(:pause)
    end
  end
end
