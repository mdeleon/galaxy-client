module Galaxy
  class Region < Galaxy::Base

    belongs_to :current_deal, :class => Deal
    has_many :from_ip, :class => Region
    has_many :deals

    class << self
      def active_from_ip(ip)
        object_or_nil do
          region = self.from_ip(ip)
          return region if region.active
        end
      end

      def from_ip(ip)
        model_for.new(get(:from_ip, :ip => ip), true)
      end

      def by_id_or_nil(id)
        object_or_nil { Region.find(id) }
      end

      def selectable_regions
        find(:all).select{|r| r.selectable?}
      end

      def nation_region_id
        "united-states"
      end
      alias :national_region_id :nation_region_id

      def national
        @national ||= Region.find("united-states")
      end

      def all
        super.select { |r| r.selectable? }
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

    def national?
      id == 'united-states'
    end

    def selectable
      active? && !!(super)
    end
    alias_method :selectable?, :selectable

    def live_deals
      active ? deals(:filter => [:in_flight, :daily_deals, :not_ended]) : []
    end

    def active?
      !!(active)
    end
  end
end
