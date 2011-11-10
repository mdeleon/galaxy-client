module Galaxy
  # The Email resource is responsible for creating transactional emails through Galaxy.
  class Email < Galaxy::Base

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

    def self.recommend_deal(from, to_emails, deal_id, msg=nil)
      post(:recommend_deal, :from => from, :emails => to_emails, :deal_id => deal_id, :msg => msg)
    end
  end
end
