module Galaxy
  class Email < Galaxy::Base
    def self.invite(from, to_emails, msg=nil)
      post(:invite, :from => from, :emails => to_emails, :msg => msg)
    end

    def self.recommend_deal(from, to_emails, deal_id, msg=nil)
      post(:recommend_deal, :from => from, :emails => to_emails, :deal_id => deal_id, :msg => msg)
    end
  end
end
