module Galaxy
  class Region < Galaxy::Base
    def current_deal
      Galaxy::Deal.new(get(:current_deal))
    end

    def deals(filter={})
      @deals ||= Galaxy::Deal.find(:all, :from => "/api/v2/regions/#{self.id}/deals.json", :params => filter)
    end
  end
end
