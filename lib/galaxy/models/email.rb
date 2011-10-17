module Galaxy
  class Region < Galaxy::Base
    def self.invite(from, to, emails, msg=nil)
      post(:invite, :from => from, :to => to, :emails => emails, :msg => msg)
    end

    def self.recommend_deal(from, to, deal_id, msg=nil)
      post(:recommend_deal, :from => from, :to => to, :deal_id => deal_id, :msg => msg)
    end
  end
end
