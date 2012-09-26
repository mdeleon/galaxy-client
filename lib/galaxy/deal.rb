module Galaxy
  class Deal < Galaxy::Base
    extend Timeify

    timeify :start_at, :end_at, :expiry_as_of_now

    alias :starting_price :price
    alias :product_name   :title
    alias :show_map?      :show_map
    alias :hide_addresses? :hide_addresses
    alias :soldout?       :soldout
    alias :number_sold    :num_purchased
    alias :ended?         :ended

    has_many :purchases
    has_many :locations
    has_many :secondary_deals, :class => Deal
    has_one  :merchant
    has_one  :region

    # TODO: remove after updating conumser web to user :user_id as param instead of user as param

    # Retrieves the secondary deals for a specific deal instance.  By default, this
    #  will retrieve other deals from the same region and national.
    # @param [User]
    #   If a user is passed, then the user's subscribed regions can be used as a source of
    #   secondary deals.
    # @return [Array]
    #   Returns an array of deal objects.  Does not include the current deal instance.
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

    def time_left
      Time.now - end_at
    end

    def discount
      value - price
    end

    def discount_percentage
      discount.to_f/value.to_f*100
    end

    def ended?
      self.end_at < Time.now
    end

    def max_purchasable(user)
      num_already_purchased = user ? user.num_already_purchased(self) : 0
      [self.purchasable_number, (self.max_per_user || 10) - num_already_purchased].min
    end

    def in_flight?
      self.workflow_state == 'in-flight'
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

    def show_closed_at
      if end_at && end_at <= Time.now
        end_at
      else
        1.day.ago.in_time_zone(self.region.timezone).end_of_day
      end
    end

    alias :has_instructions? :instructions?
    def instructions?
      !instructions.blank?
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

    def last_purchase(opts={})
      p = opts[:user] ? opts[:user].purchases : purchases
      p.select{ |x| x.deal_id == id }.sort{ |x, y| y.created_at <=> x.created_at}.first
    end

    #TODO: remove after consumer web deploy has updated to only user last_purchase
    def last_purchase_for_user(user)
      return nil unless user
      p = user.purchases.select { |x| x.deal_id == id }
      p.sort { |x, y| y.created_at <=> x.created_at}.first
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

    alias :image_url_abs :image_url
    def image_url(size="medium")
      i = image(size) and i[:url]
    end

    def image(size="medium")
      images.select{|x| x.has_key(size)}.first
    end


    def merchant_name
      merchant.try(:name)
    end

    def merchant_web
      merchant.try(:website)
    end

    def merchant_addresses
      self.eager_locations.map{|x| x[:address]}.compact
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
  end
end
