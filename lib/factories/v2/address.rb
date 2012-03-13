load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :address, :class => Hoodwink::Models::Address do
    ignore do
      merchant { Factory(:merchant) }
    end

    merchant_id   { merchant.id   }

    street      { Faker::Address.steet_address    }
    locality    { Faker::Address.city             }
    region      { Faker::Address.city             }
    merchant_id { merchant.id                     }
    country     { Faker::Address.country          }
    postal_code { Faker::Address.zip_code         }
    latitude    { Faker::Address.latitude         }
    longitude   { Faker::Address.longitude        }
    type        { "TODO address_type"             }
    created_at  { FactoryGirl.generate(:far_past) }

    id          { [street, locality, region].slugify }
  end
end

# module V2::Address
#   class DefaultSerializer
#     def self.as_json(address, opts={})
#       {
#         :id => address.slug,
#         :street => address.street,
#         :locality => address.locality,
#         :region => address.region,
#         :merchant_id => address.merchant.slug,
#         :country => address.country,
#         :postal_code => address.postal_code,
#         :latitude => address.latitude,
#         :longitude => address.longitude,
#         :type => address.type,
#         :created_at => address.created_at
#       }
#     end
#   end
# end
