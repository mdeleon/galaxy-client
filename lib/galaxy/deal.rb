module Galaxy
  class Deal < Galaxy::Base
    extend Timeify

    timeify :start_at, :end_at, :expiry_as_of_now

    alias :starting_price, :price
    alias :product_name, :title
    alias :show_map?, :show_map
    alias :hide_addresses?, :hide_addresses


    def locations(params={})
      @locations ||= if self.respond_to(:locations)
        self.locations.map{ |x| model_for(:location).new(x) }
      else
        model_for(:location).find(
          :all, :from => "/#{self.class.path}/deals/#{self.id}/locations.json",
          :params => params
          )
      end
    end

    def merchant
      @merchant ||= if self.respond_to?(:merchant)
        model_for(:merchant).find(self.merchant_id)
      else
        model_for(:merchant).new(self.merchant)
      end
    end

    def region
      @region ||= if self.respond_to?(:region)
        model_for(:region).find(self.region_id)
      else
        model_for(:region).new(self.region)
      end
    end

    def purchases(params={})
      params ||= {}
      params.merge(:deal_id => self.id)
      get(:purchases, params).map { |attrs| model_for(:purchase).new(attrs) }
    end

    # Retrieves the secondary deals for a specific deal instance.  By default, this will retrieve other deals from the same region and national.
    # @param [User]
    #   If a user is passed, then the user's subscribed regions can be used as a source of secondary deals.
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


    def last_purchase
      self.purchases(:limit => 1).first
    end

    def last_purchase_for_user(user)
      return nil unless user
      purchases = user.purchases.select { |x| x.deal_id == id }
      purchases.sort { |x, y| y.created_at <=> x.created_at}.first
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

    def inventory_limit(global=false)
      global ? self.stats[:global_inventory_limit] : super
    end

    def num_left
      self.stats[:num_left]
    end

    alias :number_sold :num_purchased
    def num_purchased(global=false)
      global ? self.stats[:global_num_purchased] : self.stats[:num_purchased]
    end

    alias :image_url_abs :image_url
    def image_url(size="medium")
      i = image(size) and i[:url]
    end

    def image(size="medium")
      images.select{|x| x.has_key(size)}).first
    end

    def merchant_id
      merchant.try(:id)
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

    def region_id
      self.region.try(:slug)
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
