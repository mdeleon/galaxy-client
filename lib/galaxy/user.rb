module Galaxy
  class User < Galaxy::Base
    has_many :deals
    has_many :matches

    # lockdown schema if we want.
    # self.schema = {'name' => :string, 'age' => :integer, 'token' => :string }


    # @return [Galaxy::User]
    def self.find_by_token(token)
      find(:all, from: "/api/v2/users/find_by_token.json", params: {token: token})
    end

    # @return [Galaxy::User]

    def self.find_by_email(email)
      find(:all, from: "/api/v2/users/find_by_email.json", params: {email: email})
    end

    # @return [Galaxy::User]
    #   Return the authenticated user
    def self.authenticate(email, passwd)
      new(get(:authenticate, email: email, pass: passwd), true)
    end

    def reset_password(token, pass, pass_confirmation)
      params = { token: token, pass: pass, pass_confirmation: pass_confirmation }
      put(:reset_password, params)
    end

    def blacklist
      put(:blacklist)
    end

    # @return [Array]
    #   Returns all purchases for the user instance.
    # The purchases will be memoized.
    # @example
    #   user.purchases # => does network request
    #   user.purchases # => returns purchases from original request (no request)
    def purchases(params={})
      @purchases ||= model_for(:purchase).find(:all, :from => "/#{self.class.path}/users/#{self.id}/purchases.json", :params => params)
    end

    # @return [Array]
    #   Returns all subscriptions for the user instance.
    # The subscriptions will be memoized.
    # @example
    #   user.subscriptions # => does network request
    #   user.subscriptions # => returns subscriptions from original request (no request)
    def subscriptions
      @subscriptions ||= model_for(:subscription).find(:all, :from => "/#{self.class.path}/users/#{self.id}/subscriptions.json")
    end

    # @return [Array]
    #   Returns all credit cards for the user instance.
    # The credit cards will be memoized.
    # @example
    #   user.credit_cards # => does network request
    #   user.credit_cards # => returns credit cards from original request (no request)
    def credit_cards
      @credit_cards ||= model_for(:credit_card).find(:all, :from => "/#{self.class.path}/users/#{self.id}/credit_cards.json")
    end

    # @return [Array]
    #   Returns all active purchases for the user instance.
    # The purchases will be memoized.
    # @example
    #   user.active_purchases # => does network request
    #   user.active_purchases # => returns purchases from original request (no request)
    def active_purchases
      @active_purchases ||= model_for(:purchase).find(:all, :from => "/#{self.class.path}/users/#{self.id}/purchases.json", :params => { :filter => "active" })
    end

    # @return [Array]
    #   Returns all coupons for the user instance.
    # The coupons will be memoized.
    # @example
    #   user.coupons # => does network request
    #   user.coupons # => returns coupons from original request (no request)
    def coupons
      @coupons ||= model_for(:coupon).find(:all, :from => "/#{self.class.path}/users/#{self.id}/coupons.json")
    end

    # @return [Array]
    #   Returns all active coupons for the user instance.
    # The coupons will be memoized.
    # @example
    #   user.active_coupons # => does network request
    #   user.active_coupons # => returns coupons from original request (no request)
    def active_coupons
      @active_coupons ||= model_for(:coupon).find(:all, :from => "/#{self.class.path}/users/#{self.id}/coupons.json", :params => { :filter => "active" })
    end


  end
end


















