module Galaxy
  class CardLink < Galaxy::Base
    belongs_to :deal
    has_many :purchases
    timeify :created_at, :fulfilled_at

    def self.linked(deal_id, user_id)
      find(:first, :from => "/api/v2/card_links/linked.json", :params => { :deal_id => deal_id, :user_id => user_id})
    end

    def self.create_or_relink(user_id, deal_id, card_link)
     card_link ||= CardLink.create(:user_id => user_id, :deal_id => deal_id)
     card_link.link
    end

    def link
      model_for(:card_link).new(JSON.parse(put(:link).body))
    end

    def unlink
      model_for(:card_link).new(JSON.parse(put(:unlink).body))
    end

    def linked?
      state == 'linked'
    end

    def expired?
      deal.expires_at && deal.expires_at <= Time.now
    end

    def fulfilled?
      state == 'fulfilled'
    end
  end
end
