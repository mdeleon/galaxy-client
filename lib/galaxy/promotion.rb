module Galaxy
  class Promotion < Galaxy::Base
    extend Timeify

    timeify :start_at
    timeify :end_at
    timeify :expire_at

    # Apply a promotion to user
    # @param [Hash] params
    #   :user_id is the id of the user that we will apply the promotion for.
    def apply_to_user(user_id)
      params = {:user_id => user_id}
      post(:apply_to_user, params)
    end

    def start_date
      start_at && start_at.strftime('%m/%d/%Y');
    end

    def end_date
      end_at && end_at.strftime('%m/%d/%Y');
    end

    def expire_date
      expire_at && expire_at.strftime('%m/%d/%Y');
    end

    def formated_quantity
      quantity.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
    end

    def cancelled?
      state == 'cancelled'
    end

    def sold_out?
      !quantity.nil? && (redemptions >= quantity)
    end

    def ended?
      !end_at.nil? && end_at <= Time.now
    end

    def active?
      state == 'active'
    end

    def started?
      (start_at <= Time.now)
    end
  end
end
