module Galaxy
  class Deal < Galaxy::Base
    timeify :start_at, :end_at, :expiry_as_of_now, :expires_at

    has_many :purchases
    has_many :locations
    has_many :secondary_deals, :class => Deal
    belongs_to  :merchant
    belongs_to  :region

    # TODO: remove after updating conumser web to user :user_id as param instead of user as param
    def secondary_deals(user=nil, params={})
      user && params.merge(:user_id => user.id)
      get(:secondary_deals, params).map { |attrs| model_for(:deal).new(attrs) }
    end

    def started?
      !!(start_at && start_at <= Time.now)
    end

    def running?
      started? and !ended?
    end

    def expired?
      soldout? or ended?
    end
    # which one?
    # def expired?
    #   soldout? or expires_at and expires_at <= Time.zone.now
    # end

    def time_left
      Time.now - end_at
    end

    def soldout?
      soldout
    end

    def discount
      value - price
    end

    def hide_addresses?
      hide_addresses
    end

    def show_map?
      show_map
    end

    def product_name
      title
    end

    def highlights
      super || ""
    end

    def time_left_hash
      remaining_time = time_left.round
      total = remaining_time
      days = remaining_time / 1.day
      hours = (remaining_time -= days.days) / 1.hour
      minutes = (remaining_time -= hours.hours) / 1.minute
      seconds = (remaining_time -= minutes.minutes) / 1.second
      {
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        total: total
      }
    end

    def calculate_cost(user, qty)
      if user and user.credits > 0
        subtotal = price * qty
        credit = [subtotal, user.credits].min
        total = subtotal - credit
      else
        credit = 0
        subtotal = price * qty
        total = subtotal
      end

      [credit, subtotal, total]
    end

    def starting_price
      price
    end

    def discount_percentage
      discount.to_f/value.to_f*100
    end

    def number_sold
      num_purchased
    end

    def ended?
      end_at and self.end_at < Time.now
    end
    alias :ended :ended?

    def self.find_by_regions(region_ids, user = nil)
      in_flight_deals = []
      region_ids.uniq.each do |region_id|
        region =  Region.find(region_id)
        if user
          in_flight_deals.concat region.deals(:filter => "in_flight", :user_id => user.id).reject{ |d| user.fulfilled_deal?(d) }
        else
          in_flight_deals.concat region.deals(:filter => "in_flight")
        end
      end

      in_flight_deals.reject!{ |deal| deal.soldout || deal.expired? }

      # sort deals with the most current start_at deal at the top
      in_flight_deals.sort_by { |deal| deal.start_at.to_i*-1 }
    end

    def card_linked?
      type == "card-linked"
    end

    def purchasable?(user=nil)
      max_purchasable_per_transaction(user) > 0
    end

    def max_purchasable(user)
      num_already_purchased = user ? user.num_already_purchased(self) : 0
      [self.purchasable_number, (self.max_per_user || 10) - num_already_purchased].compact.min
    end
    alias :max_purchasable_per_transaction :max_purchasable

    def in_flight?
      state == 'in-flight'
    end

    def approved?
      %w[ approved in-flight landed ].include? state
    end

    def expiry(timezone = region.timezone)
      expiry_as_of_now ? expiry_as_of_now.in_time_zone(timezone) : nil
    end

    def buyable?(user=nil)
      started? && !expired? && in_flight? && max_purchasable(user) > 0
    end

    def instructions?
      !instructions.blank?
    end
    alias :has_instructions? :instructions?

    def redemption_coded?
      fulfillment_method == "redemptioncoded"
    end

    def printable?
      fulfillment_method == "printed"
    end

    def sent_by_mail?
      fulfillment_method == 'shipped'
    end

    def last_purchase(opts={})
      p = opts[:user] ? opts[:user].purchases : purchases
      p.select{ |x| x.deal_id == id }.sort{ |x, y| y.created_at <=> x.created_at}.first
    end

    #TODO: remove after consumer web deploy has updated to only user last_purchase
    def last_purchase_for_user(user)
      return nil unless user
      last_purchase({:user => user})
    end

    def external_purchase_url?
      !external_purchase_url.blank?
    end

    # Helper method to ensure custom_data returns a hash of attributes instead of a CustomData object.
    # @return [Hash]
    #   The hash corresponding to the custom data fields.
    def custom_data
      super.attributes
    end

    def ended
      Time.now > self.end_at
    end

    def image_url(size="medium")
      i = image(size) and i[:url]
    end
    alias :image_url_abs :image_url

    def image(size="medium")
      images.select{|x| x.has_key(size)}.first
    end


    def merchant_name
      merchant.try(:name)
    end

    def merchant_web
      merchant.try(:website)
    end

    def region_name
      self.region.try(:name)
    end

    def phone_numbers
      self.locations.map{|x| x.phone}
    end

    def addresses
      self.locations.map{|x| x.readable_address}
    end
    alias :merchant_addresses :addresses

    #Helper method
    def timezone
      region.timezone
    end

    # Helper method
    def national?
      region.id == 'united-states'
    end
  end
end
