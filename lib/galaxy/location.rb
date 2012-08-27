module Galaxy
  class Location < Galaxy::Base
    timeify :created_at
    def address
      if address_id
        model_for(:address).find(self.address_id)
      end
    end
  end
end
