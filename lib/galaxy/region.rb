module Galaxy
  class Region < Galaxy::Base
    def current_deal
      model_for(:deal).new(get(:current_deal))
    end

    def deals(filter={})
      @deals ||= model_for(:deal).find(:all, :from => "/api/v2/regions/#{self.id}/deals.json", :params => filter)
    end

    def self.from_ip(ip)
      model_for.new(get(:from_ip, :ip => ip), true)
    end
  end
end
