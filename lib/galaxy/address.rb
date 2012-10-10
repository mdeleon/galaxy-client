module Galaxy
  class Address < Galaxy::Base
    def to_s
      output =  [street, locality, region].compact.join(', ')
      output << " #{ postal_code ? postal_code[0..4] : '' }"
      output.strip
    end

    def city_state_zip
      "#{locality}, #{region} #{postal_code ? postal_code[0..4] : ''}".strip
    end
  end
end
