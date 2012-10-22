module Galaxy
  class Subscription < Galaxy::Base
    belongs_to :user

    timeify :created_at

    def regional?
      !national?
    end

    def national?
      region_id == 'united-states'
    end

    def has_region?
      respond_to?(:region_id) && region_id.present?
    end

    def unsubscribe
      unless inactive?
        self.status = "inactive" and save!
      end
      self
    end

    def subscribe
      unless active?
        self.status = "active" and save!
      end
      self
    end

    def active?
      self.status == "active"
    end

    def inactive?
      !active?
    end

    def pause
      put(:pause)
    end
  end
end
