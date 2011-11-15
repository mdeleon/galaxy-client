module Galaxy
  class Region < Galaxy::Base
    def current_deal
      get(:current_deal)
    end

    def deals
      @deals ||= Galaxy::Deal.find(:all, :from => "/api/v2/regions/#{self.id}/deals.json")
    end
  end
end
