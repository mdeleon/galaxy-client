module Galaxy
  class Region < Galaxy::Base
    def current_deal
      get(:current_deal)
    end
  end
end
