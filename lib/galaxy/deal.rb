module Galaxy
  class Deal < Galaxy::Base

    # Retrieves the secondary deals for a specific deal instance.
    # @return [Array]
    #   Returns an array of deal objects.  Does not include the current deal instance.
    def secondary_deals
      put(:secondary_deals)
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
      @merchant ||= Galaxy::Merchant.find(self.merchant_id)
    end

    # Parses the end_at String since JSON doesn't support time objects.
    def end_at
      Time.parse(super)
    end

    def custom_data
      super.attributes
    end
  end
end
