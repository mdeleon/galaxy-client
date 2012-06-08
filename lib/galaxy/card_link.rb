module Galaxy
  class CardLink < Galaxy::Base
    many_to_one :deal

    def self.linked(deal_id, user_id)
      find(:first, :from => "/api/v2/card_links/linked.json", :params => { :deal_id => deal_id, :user_id => user_id})
    end

    def link
      model_for(:card_link).new(JSON.parse(put(:link).body))
    end

    def unlink
      model_for(:card_link).new(JSON.parse(put(:unlink).body))
    end
  end
end
