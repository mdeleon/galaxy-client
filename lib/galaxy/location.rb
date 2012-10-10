module Galaxy
  class Location < Galaxy::Base
    def address
      model_for(:address).new(self.address)
    end
  end
end
