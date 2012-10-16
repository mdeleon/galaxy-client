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
      self.status = "inactive"
      save!
    end

    def subscribe
      self.status = "active"
      save!
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

    def modifiable?
      true
    end
  end
end
