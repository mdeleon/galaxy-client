module Galaxy
  class Purchase < Galaxy::Base
    def checkout
      put(:checkout)
    end
  end
end
