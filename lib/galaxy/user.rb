module Galaxy
  class User < Galaxy::Base
    extend Timeify
    timeify :last_login_at, :created_at

    has_many :deals
    has_many :matches
    has_many :administered_merchants, :class => User
    has_many :active_purchases, :class => Purchase, :default_params => Proc.new{ {:filter => "active"} }
    has_many :credit_cards
    has_many :subscriptions
    has_many :purchases
    has_many :saved_deals
    has_many :card_links
    has_many :coupons
    has_many :category_preferences

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

    def self.from_email_token(email_token)
      email = Email.find(email_token)
      return nil if email.nil?

      # test daily update email might not have to 'to_user_id' field populated, so for now
      # we also inspect the 'to' field to find the user associate with the email
      return User.find(email.to_user_id) if email.to_user_id
      return User.find_by_email(email.to).first if email.to
      nil
    end

    def self.find_by_token(token)
      find(:all, from: "/api/v2/users/find_by_token.json", params: {token: token})
    end

    def self.find_by_email(email)
      find(:all, from: "/api/v2/users/find_by_email.json", params: {email: email})
    end

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

    def self.email_token_subscribe?(email_token, region_id)
      user = User.from_email_token(email_token)
      user ? user.has_subscribed?(region_id) : nil
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

    def best_name
      full_name.blank? ? email : full_name
    end

    def full_name
      "#{self.firstname}#{self.lastname && " #{self.lastname}"}".strip
    end

    def has_firstname?
      firstname.present?
    end

    def has_lastname?
      lastname.present?
    end

    def has_full_name?
      has_firstname? && has_lastname?
    end


    ##======================= PURCHASE STUFF ===============================

    def num_already_purchased(deal)
      active_purchases.map { |x| x.deal_id == deal.id ? x.num_bought : 0}.reduce(&:+) || 0
    end

    def active_purchases
      purchases.keep_if{|purchase| purchase.active? }
    end

    def has_purchased?(deal)
      if deal.card_linked?
        card_links.any? { |card_link| card_link.deal_id == deal.id && card_link.state != "unlinked"}
      else
        coupons.any? { |coupon| coupon.deal_id == deal.id && coupon.state != "cancelled" }
      end
    end

    def find_purchase(purchase_id)
      purchases.find { |purchase| purchase.id.to_s == purchase_id }
    end

    ##======================= COUPON STUFF ===============================

    def active_coupons
      coupons.keep_if{|coupon| coupon.active?}.reverse
    end

    def valid_coupons_for_purchase(purchase_id)
      purchase = find_purchase(purchase_id)
      purchase ? purchase.valid_coupons : []
    end

    def find_coupon(coupon_id)
      coupons.find { |c| c.id.to_s == coupon_id }
    end

    ##======================= SUBSCRIPTION STUFF ===============================

    def active_subscriptions
      subscriptions.select { |s| s.active? }.sort{|x,y| y.created_at <=> x.created_at} || []
    end

    def has_subscribed?(region_id)
      !!(subscriptions.find {|s| s.region_id == region_id && s.active? })
    end

    def unique_subscriptions_by_region
      subscriptions.uniq_by { |sub| sub.region_id }
    end

    def unsubscribe_from_all
      subscriptions.each do |s|
        s.unsubscribe if s.active?
      end
    end

    def subscribe_by_region(region)
      #clear the cache of galaxy-client
      @subscriptions = nil
      region = region.id if region.is_a? Region

      if sub = subscriptions.find { |s| s.region_id == region }
        sub.subscribe
      else
        Subscription.create(:user_id => id, :region_id => region)
      end
    end

    def subscribe_by_zip(zip=nil)
      @subscriptions = nil
      Subscription.create(:zip => zip || self.postal_code, :user_id => self.id)

      self.subscriptions.each do |s|
        if s.active?
          r = Region.find(s.region_id)
          s.unsubscribe if r && !r.active?
        end
      end
    end

    ##======================= CARD LINKS STUFF ===============================

     def fulfilled_deal?(deal)
      if deal.card_linked?
        card_link_for(deal.id).try(:fulfilled?)
      else
        coupons.find { |coupon| coupon.deal_id == deal.id && coupon.redeemed? }
      end
    end

    def card_links_for_merchant(merchant)
      card_links.select { |cardl| cardl.merchant_id == merchant.id }
    end

    def relink_deal(deal)
      card_links_for_merchant(deal.merchant).each do |card_link|
        card_link.unlink if card_link.linked?
      end

      link_deal(deal.id)
    end

    def link_deal(deal_id)
      existing_card_link = card_link_for(deal_id)
      if existing_card_link.try(:linked?)
        'linked_already'
      else
        CardLink.create_or_relink(self.id, deal_id, existing_card_link)
        self.reload
        unsave_deal(deal_id)
        'success'
      end
    end

    def unlink_deal(deal_id)
      card_link_for(deal_id).try(:unlink)
    end

    def card_linked?(deal)
      card_link_for(deal.id).try(:linked?)
    end


    def daily_deal_coupons
      offer_ids = card_links.map(&:deal_id)
      coupons.select { |c| !offer_ids.include?(c.deal_id) }
    end

    def card_link_for(deal_id)
      card_links.find { |cl| cl.deal_id == deal_id}
    end

    ##========================== SAVED DEAL STUFF   ==================================

    def category_active_for?(category)
      !!category_preferences.try(:any?) { |cp| cp.category_id == category.id }
    end

    def save_deal(deal_id)
      if !saved_deals.any? { |deal| deal.deal_id == deal_id }
        SavedDeal.create(:user_id => self.id, :deal_id => deal_id)
      end
    end

    def unsave_deal(deal_id)
      saved_deal = saved_deals.find { |deal| deal.deal_id == deal_id }
      saved_deal.try(:destroy)
    end

    def is_saved?(deal)
      saved_deals.any? { |cl| cl.deal_id == deal.id }
    end
  end
end
