module Galaxy
  class Deal < Galaxy::Base
    timeify :start_at, :end_at, :expiry_as_of_now, :expires_at

    has_many :locations

    # Retrieves the secondary deals for a specific deal instance.  By default, this will retrieve other deals from the same region and national.
    # @param [User]
    #   If a user is passed, then the user's subscribed regions can be used as a source of secondary deals.
    # @return [Array]
    #   Returns an array of deal objects.  Does not include the current deal instance.
    def secondary_deals(user=nil, params={})
      user && params.merge(:user_id => user.id)
      get(:secondary_deals, params).map { |attrs| model_for(:deal).new(attrs) }
    end

    # Retrieves the region for a specific deal instance.
    # The region will be memoized.
    # @example
    #   deal.region # => does network request
    #   deal.region # => returns region from original request (no request)
    def region
      @region ||= model_for(:region).find(self.region_id)
    end

    def purchases(params={})
      params ||= {}
      params.merge(:deal_id => self.id)
      get(:purchases, params).map { |attrs| model_for(:purchase).new(attrs) }
    end

    # Retrieves the merchant for a specific deal instance.
    # The merchant will be memoized.
    # @example
    #   deal.merchant # => does network request
    #   deal.merchant # => returns merchant from original request (no request)
    def merchant
      # TODO: modify for eager loading of objects...
      @merchant ||= model_for(:merchant).find(self.merchant_id)
    end

    # Helper method to ensure custom_data returns a hash of attributes instead of a CustomData object.
    # @return [Hash]
    #   The hash corresponding to the custom data fields.
    def custom_data
      super.attributes
    end

    # Helper method.
    def discount
      value - price
    end

    # Helper method.
    def discount_percentage
      discount.to_f/value.to_f*100
    end
    
    #Helper method
    def timezone
      region.timezone
    end  

    # Helper method
    def is_national?
      region.slug == 'united-states'
    end  
  end
end
