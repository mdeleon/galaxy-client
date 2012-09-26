module Galaxy
  class User < Galaxy::Base
    has_many :deals
    has_many :matches
    has_many :administered_merchants, :class => User
    has_many :active_purchases, :class => Purchase, :default_params => Proc.new{ {:filter => "active"} }
    has_many :credit_cards
    has_many :subcriptions
    has_many :purchases

    # lockdown schema if we want.
    # self.schema = {'name' => :string, 'age' => :integer, 'token' => :string }

    def self.find_external_admin_by_email(email)
      begin
        get(:find_external_admin_by_email, :email => email).map do |json|
          new json
        end
      rescue ActiveResource::ResourceNotFound
        []
      end
    end

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
    rescue ActiveResource::ResourceInvalid => e
      instance = new(email: email, pass: passwd)
      instance.load_remote_errors(e)
      raise ActiveResource::ResourceInvalid.new(instance)
    end

    def self.authenticate_external_admin(email, passwd)
      new(get(:authenticate_external_admin, email: email, pass: passwd), true)
    rescue ActiveResource::ResourceInvalid => e
      instance = new(email: email, pass: passwd)
      instance.load_remote_errors(e)
      raise ActiveResource::ResourceInvalid.new(instance)
    end

    def reset_password(token, pass, pass_confirmation)
      params = { token: token, pass: pass, pass_confirmation: pass_confirmation }
      put(:reset_password, params)
    rescue ActiveResource::ResourceInvalid => e
      load_remote_errors(e)
      raise ActiveResource::ResourceInvalid.new(self)
    end

    def blacklist
      put(:blacklist)
    end

    def num_already_purchased(deal)
      active_purchases.map { |x| x.deal_id == deal.id ? x.num_bought : 0}.reduce(&:+) || 0
    end

    def active_purchases
      purchases.keep_if{|purchase| purchase.active? }
    end

    def active_coupons
      coupons.keep_if{|coupon| coupon.active?}
    end
  end
end


















