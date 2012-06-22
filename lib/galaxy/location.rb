module Galaxy
  class Location < Galaxy::Base
    def address
      model_for(:address).new self.location_address.attributes
    end
  end
end
