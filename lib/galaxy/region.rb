module Galaxy
  class Region < Galaxy::Base
    def current_deal
      model_for(:deal).new(get(:current_deal))
    end

    alias_method :selectable?, :selectable
    def selectable
      # region has to be active in order to be selectable.
      active? && !!(super)
    end

    def self.selectable_regions
      find(:all).select{|r| r.selectable?}
    end


    def national?
      id == 'united-states'
    end

    def nation_region_id
      "united-states"
    end


    def national
      Region.find("united-states")
    end

    def all
      super.select { |r| r.selectable? }
    end

    def active?
      !!(active)
    end

    def deals(filter={})
      @deals ||= if self.respond_to(:deals)
        self.deals.map{ |x| model_for(:deal).new(x) }
      else
        model_for(:deal).find(
          :all, :from => "/api/v2/regions/#{self.id}/deals.json",
          :params => params
          )
      end
    end

    def self.from_ip(ip)
      model_for.new(get(:from_ip, :ip => ip), true)
    end
  end
end
