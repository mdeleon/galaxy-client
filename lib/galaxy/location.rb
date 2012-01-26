module Galaxy
  class Location < Galaxy::Base
    def address
      model_for(:address).find(self.address_id)
    end
  end
end
