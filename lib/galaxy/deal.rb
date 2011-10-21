module Galaxy
  class Deal < Galaxy::Base

    # Retrieves the secondary deals for a specific deal instance.  By default, this will retrieve other deals from the same region and national.
    # @param [User]
    #   If a user is passed, then the user's subscribed regions can be used as a source of secondary deals.
    # @return [Array]
    #   Returns an array of deal objects.  Does not include the current deal instance.
    def secondary_deals(user=nil)
      params = {}
      user && params.merge(:user_id => user.id)
      get(:secondary_deals, params).map { |attrs| Deal.new(attrs) }
    end

    # Retrieves the region for a specific deal instance.
    # The region will be memoized.
    # @example
    #   deal.region # => does network request
    #   deal.region # => returns region from original request (no request)
    def region
      @region ||= Galaxy::Region.find(self.region_id)
    end

    # Retrieves the merchant for a specific deal instance.
    # The merchant will be memoized.
    # @example
    #   deal.merchant # => does network request
    #   deal.merchant # => returns merchant from original request (no request)
    def merchant
      # TODO: modify for eager loading of objects...
      @merchant ||= Galaxy::Merchant.find(self.merchant_id)
    end

    # Parses the time String since JSON doesn't support time objects.
    def start_at
      Time.parse(super)
    end

    # Parses the time String since JSON doesn't support time objects.
    def end_at
      Time.parse(super)
    end

    # Helper method to ensure custom_data returns a hash of attributes instead of a CustomData object.
    # @return [Hash]
    #   The hash corresponding to the custom data fields.
    def custom_data
      super.attributes
    end

    # Helper method.
    def discount
      value - current_price
    end

    # Helper method.
    def discount_percentage
      discount.to_f/value.to_f*100
    end
  end
end
