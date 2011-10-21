module Galaxy
  class User < Galaxy::Base
    # lockdown schema if we want.
    # self.schema = {'name' => :string, 'age' => :integer }

    def self.find_or_create_by_email(params)
      new(post(:find_or_create_by_email, :user => params))
    end

    def reset_password
      put(:reset_password)
    end

    def blacklist
      put(:blacklist)
    end

    # @return [Array]
    #   Returns all purchases for the user instance.
    # @example
    #   user = Galaxy::User.find("b9d30f09")
    #   user.purchases
    def purchases
      @purchases ||= Galaxy::Purchase.find(:all, :from => "/#{self.class.path}/users/#{self.id}/purchases.json")
    end

    def active_purchases
      @active_purchases ||= Galaxy::Purchase.find(:all, :from => "/#{self.class.path}/users/#{self.id}/purchases.json", :params => { :filter => "active" })
    end
  end
end
