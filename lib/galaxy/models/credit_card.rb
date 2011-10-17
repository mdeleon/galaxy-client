module Galaxy
  class CreditCard < Galaxy::Base
    def make_primary
      put(:make_primary)
    end
  end
end
