load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :subscription, :class => Hoodwink::Models::Subscription do
    ignore do
      user   { Factory(:user)   }
      region { Factory(:region) }
    end

    user_id     { user.id     }
    region_id   { region.id   }
    region_name { region.name }

    status     { ["active", "inactive"].sample }
    zip        { Faker::Address.zip_code }
    source     { "TODO: subscription source" }
    created_at { FactoryGirl.generate(:far_past) }
    confirmed  { FactoryGirl.generate(:boolean) }

    id          { [user_id, region_id, region_name].slugify }
  end
end

# module V2::Subscription
#   class DefaultSerializer
#     def self.as_json(s, opts={})
#       {
#         :id => s.slug,
#         :user_id => s.user && s.user.slug,
#         :region_id => s.region && s.region.slug,
#         :region_name => s.region && s.region.name,
#         :status => s.subscribed? && 'active' || 'inactive',
#         :zip => s.zip,
#         :source => s.user && s.user.source,
#         :created_at => s.created_at,
#         :confirmed => s.user && s.user.is_confirmed
#       }
#     end
#   end
# end
