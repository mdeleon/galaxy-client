load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :saved_deal, :class => Hoodwink::Models::SavedDeal do
    ignore do
      deal { Factory(:deal) }
      user { Factory(:user) }
    end

    deal_id { deal.id }
    user_id { user.id }

    created_at  { FactoryGirl.generate(:far_past) }

    id          { [deal_id, user_id].slugify }
  end
end

# module V2::SavedDeal
#   class DefaultSerializer
#     def self.as_json(saved_deal, opts={})
#       {
#         :id => saved_deal.slug,
#         :deal_id => saved_deal.deal.slug,
#         :user_id => saved_deal.user.slug,
#         :created_at => saved_deal.created_at
#       }
#     end
#   end
# end
