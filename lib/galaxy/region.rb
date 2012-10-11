module Galaxy
  class Region < Galaxy::Base

    belongs_to :current_deal, :class => Deal
    has_many :deals

    class << self
      def active_from_ip(ip)
        object_or_nil do
          region = self.from_ip(ip)
          return region if region.active
        end
      end

      def by_id_or_nil(id)
        object_or_nil { Region.find(id) }
      end

      def selectable_regions
        find(:all).select{|r| r.selectable?}
      end

      private
      def object_or_nil
        begin
          yield
        rescue ActiveResource::ResourceNotFound
          nil
        end
      end
    end

    def selectable
      # region has to be active in order to be selectable.
      active? && !!(super)
    end
    alias_method :selectable?, :selectable

    def national?
      id == 'united-states'
    end

    def nation_region_id
      "united-states"
    end

    def national
      @national ||= Region.find("united-states")
    end

    def all
      super.select { |r| r.selectable? }
    end

    def live_deals
      active ? deals(:filter => [:in_flight, :daily_deals, :not_ended]) : []
    end

    def active?
      !!(active)
    end

    def self.from_ip(ip)
      model_for.new(get(:from_ip, :ip => ip), true)
    end
  end
end
