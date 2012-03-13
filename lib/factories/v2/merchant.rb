load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :merchant, :class => Hoodwink::Models::Merchant do |d|
    ignore do
      region { Factory(:region) }
    end

    region_id { region.id }

    name      { FactoryGirl.generate(:company_name) }
    id        { name.slugify }
    website
    addresses
    phone_numbers
    email

    custom_data { "TODO: custom data" }
  end
end
    

# module V2::Merchant
#   class DefaultSerializer
#     def self.as_json(merchant, opts={})
#       { :id => merchant.slug,
#         :region_id => merchant.region.slug,
#         :custom_data => merchant.data_mappings_with_name,
#         :name => merchant.name,
#         :website => merchant.website,
#         :addresses => merchant.addresses.split("\r\n"),
#         :phone_numbers => merchant.phone_numbers.split("\r\n"),
#         :email => merchant.email
#       }
#     end
#   end
# end
