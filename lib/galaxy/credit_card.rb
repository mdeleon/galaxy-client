module Galaxy
  class CreditCard < Galaxy::Base
    def make_primary
      put(:make_primary)
    end

    def type_name
      {
        'visa'               => 'VISA',
        'master'             => 'MC',
        'discover'           => 'Discover',
        'american_express'   => 'AMEX'
      }[type] || super || (type && type.gsub(/_+/, ' ').gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase })
    end

    def display_number
      "#{type_name} - #{number.gsub('-','')[-8..-1]}"
    end
  end
end
