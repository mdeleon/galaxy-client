load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :user, :class => Hoodwink::Models::User do
    email  { FactoryGirl.generate(:email) }
    postal_code       { Faker::Address.zip_code }
    
    ignore do
      merchant { nil }
    end

    merchant_id { merchant && merchant.id || nil }    

    firstname     { Faker::Name.first_name }
    lastname      { Faker::Name.last_name }
    created_at    { FactoryGirl.generate(:far_past) }
    credits       { rand(1000) }
    share_link    { FactoryGirl.generate(:url) }
    token         { "TODO: user token" }
    num_purchased { rand(5) }
    total_savings { FactoryGirl.generate(:dollar_amount) }
    has_passwd    { FactoryGirl.generate(:boolean) }
    last_login_at { FactoryGirl.generate(:near_past) }

    id          { [purchase_id, deal_id, credit_card_id, state].slugify }
  end
end

# module V2::User
#   class DefaultSerializer
#     def self.as_json(user, opts={})
#       {
#         :id => user.slug,
#         :email => user.email || "",
#         :postal_code => user.postal_code || "",
#         :firstname => user.first_name || "",
#         :lastname => user.last_name || "",
#         :created_at => user.created_at,
#         :credits => user.credits || 0,
#         :share_link => user.manual_share.link,
#         :token => user.token,
#         :num_purchased => user.num_purchased || 0,
#         :total_savings => user.total_savings || 0,
#         :has_passwd => user.has_pass?,
#         :last_login_at => user.data[:last_login_at]
#       }
#     end
#   end
# end
