module Galaxy
  class Deal < Galaxy::Base
    timeify :start_at, :end_at, :expiry_as_of_now, :expires_at

    has_many :purchases
    has_many :locations
    belongs_to  :merchant
    belongs_to  :region

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

    def started?
      !!(start_at && start_at <= Time.now)
    end

    def running?
      started? and !ended?
    end
    
    def fine_print_list
      fine_print ? fine_print.gsub("</div>","").split("<div>") : []
    end

    def time_left
      Time.now - end_at
    end

    def soldout?
      soldout
    end
    alias :sold_out? :soldout?

    def discount
      value - price
    end

    def expired?
      soldout? || (self.expires_at and self.expires_at <= Time.now)
    end

    def hide_addresses?
      hide_addresses
    end

    def show_map?
      show_map
    end

    def highlights
      super || ""
    end

    def discount_percentage
      discount.to_f/value.to_f*100
    end

    def ended?
      end_at and self.end_at < Time.now
    end
    alias :ended :ended?

    def card_linked?
      type == "card-linked"
    end

    def in_flight?
      state == 'in-flight'
    end

    def redemption_coded?
      fulfillment_method == "redemptioncoded"
    end

    def printable?
      fulfillment_method == "printed"
    end

    def sent_by_mail?
      fulfillment_method == 'shipped'
    end

    def approved?
      %w[ approved in-flight landed ].include? state
    end

    def timezone
      region.timezone
    end

    def national?
      region.id == 'united-states'
    end

    def external_purchase_url?
      !external_purchase_url.blank?
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

    def instructions?
      !instructions.blank?
    end
    alias :has_instructions? :instructions?

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

    def purchasable?(user=nil)
      user ? (max_purchasable(user) > 0) : !soldout
    end

    def max_purchasable(user=nil)
      num_already_purchased = user ? user.num_already_purchased(self) : 0
      [self.num_left, (self.max_per_user || 10) - num_already_purchased].compact.min
    end

    def expiry(timezone = region.timezone)
      expiry_as_of_now ? expiry_as_of_now.in_time_zone(timezone) : nil
    end

    def buyable?(user=nil)
      !expired? && in_flight? && max_purchasable(user) > 0
    end

    def last_purchase(opts={})
      opts ||= {}
      p = opts[:user] ? opts[:user].purchases : purchases
      p.select{ |x| x.deal_id == id }.sort{ |x, y| y.created_at <=> x.created_at}.first
    end

    # Helper method to ensure custom_data returns a hash of attributes instead of a CustomData object.
    # @return [Hash]
    #   The hash corresponding to the custom data fields.
    def custom_data
      super.attributes
    end

    def image_url(size="medium")
      image(size).try(:url)
    end

    def image(size="medium")
      return if images.blank?
      size ||= "medium"

      images.select{|x| x.size == size}.first || images.first
    end
  end
end
