module Galaxy
  # The Email resource is responsible for creating transactional emails through Galaxy.
  class Email < Galaxy::Base

    def user
      @user ||= model_for(:user).find(self.to_user_id)
    end

    def open
      put :open
    end

    def click
      put :click
    end

    def unsubscribe
      put :unsubscribe
    end

    # Sends an invite email to multiple email address.
    # @param [Hash] params
    #   :user_id is the id of the user that we send the invitations on behalf of.
    #   :emails is a comma-seperated string of email addresses.
    #   :message is the text to customize the invite email.
    def self.invite(params={})
      params.assert_valid_keys(:user_id, :emails, :message)
      post(:invite, params)
    rescue ActiveResource::ResourceInvalid => e
      instance = new(params)
      instance.load_remote_errors(e)
      raise ActiveResource::ResourceInvalid.new(instance)
    end

    # Sends a recommend deal email to multiple email address.
    # @param [Hash] params
    #   :user_id is the id of the user that we send the invitations on behalf of.
    #   :deal_id is the id of the deal
    #   :emails is a comma-seperated string of email addresses.
    #   :message is the text to customize the invite email.
    def self.recommend_deal(params={})
      params.assert_valid_keys(:user_id, :deal_id, :emails, :message)
      post(:recommend_deal, params)
    rescue ActiveResource::ResourceInvalid => e
      instance = new(params)
      instance.load_remote_errors(e)
      raise ActiveResource::ResourceInvalid.new(instance)
    end

    def self.forgot_password(email)
      params = { email: email };
      post(:forgot_password, params)
    rescue ActiveResource::ResourceInvalid => e
      instance = new(email: params)
      instance.load_remote_errors(e)
      raise ActiveResource::ResourceInvalid.new(instance)
    end

    def self.account_change(user_id)
      params = {user_id: user_id}
      post(:account_change, params)
    rescue ActiveResource::ResourceInvalid => e
      instance = new(params)
      instance.load_remote_errors(e)
      raise ActiveResource::ResourceInvaild.new(instance)
    end

    def self.welcome(user_id)
      params = {user_id: user_id}
      post(:welcome, params)
    end
  end
end
