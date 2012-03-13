load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :location, :class => Hoodwink::Models::Location do
    ignore do
      address { Factory(:address)    }
    end

    address_id   { address.id }
    
    phone { FactoryGirl.generate(:phone_number) }
    type  { "TODO: location type" }

    created_at  { FactoryGirl.generate(:far_past) }

    id          { [address_id, phone, type].slugify }
  end
end

# module V2::Merchant::Location
#   class DefaultSerializer
#     def self.as_json(location, opts={})
#       {
#         :id => location.slug,
#         :phone => location.phone,
#         :type => location.type,
#         :address_id => location.address.slug,
#         :created_at => location.created_at
#         # need slug for parent
#       }
#     end
#   end
# end
