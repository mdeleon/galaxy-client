module Galaxy
  class Region < Galaxy::Base

    has_one  :current_deal, :class => Deal
    has_many :deals

    def selectable
      # region has to be active in order to be selectable.
      active? && !!(super)
    end
    alias_method :selectable?, :selectable

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

    def self.from_ip(ip)
      model_for.new(get(:from_ip, :ip => ip), true)
    end
  end
end
