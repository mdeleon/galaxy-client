module Galaxy
  class Subscription < Galaxy::Base

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

    def user
      @user ||= User.find(user_id)
    end

    def unsubscribe
      self.status = "inactive"
      save!
    end

    def subscribe
      self.status = "active"
      save!
    end
  end
end
