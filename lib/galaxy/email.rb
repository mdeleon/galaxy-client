module Galaxy
  # The Email resource is responsible for creating transactional emails through Galaxy.
  class Email < Galaxy::Base

    # Sends an invite email.
    # @param [String] from
    #   An email address to be used as the from address.
    # @param [Array] to_emails
    #   An array of email address strings.
    # @param [String] msg
    #   An optional message to provide to customize the invite email.
    def self.invite(from, to_emails, msg=nil)
      post(:invite, :from => from, :emails => to_emails, :msg => msg)
    end

    def self.recommend_deal(from, to_emails, deal_id, msg=nil)
      post(:recommend_deal, :from => from, :emails => to_emails, :deal_id => deal_id, :msg => msg)
    end
  end
end
