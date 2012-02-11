module Galaxy
  class Address < Galaxy::Base
    def address
      output =  [street, locality, region].compact.join(', ')
      output << " #{ postal_code ? postal_code[0..4] : '' }"
      output.strip
    end
  end
end
