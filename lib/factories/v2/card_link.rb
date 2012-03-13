load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :card_link, :class => Hoodwink::Models::CardLink do
    ignore do
      deal { Factory(:deal) }
      user { Factory(:user) }
      merchant { Factory(:merchant) }
    end

    deal_id     { deal.id     }
    user_id     { user.id     }
    merchant_id { merchant.id }

    state       { Faker::Address.state }
    created_at  { FactoryGirl.generate(:far_past) }

    id          { [deal_id, user_id, merchant_id, state].slugify }
  end
end

# module V2::CardLink
#   class DefaultSerializer
#     def self.as_json(card_link, opts={})
#       {
#         :id => card_link.slug,
#         :deal_id => card_link.deal.slug,
#         :user_id => card_link.user.slug,
#         :merchant_id => card_link.merchant.slug,
#         :state => card_link.workflow_state,
#         :created_at => card_link.created_at
#       }
#     end
#   end
# end
