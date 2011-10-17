module Galaxy
  class Deal < Galaxy::Base
    def secondary_deals
      put(:secondary_deals)
    end
  end
end
