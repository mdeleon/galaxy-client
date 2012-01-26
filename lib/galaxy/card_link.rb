module Galaxy
  class CardLink < Galaxy::Base
    def self.linked(deal_id, user_id)
      find(:first, :from => "/api/v2/card_links/linked.json", :params => { :deal_id => deal_id, :user_id => user_id})
    end
  end
end
