load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :purchase, :class => Hoodwink::Models::Purchase do
    ignore do
      deal        { Factory(:deal)        }
      user        { Factory(:user)    }
      credit_card { Factory(:credit_card) }
    end

    deal_id        { deal.id         }
    user_id        { user.id     }
    credit_card_id { credit_card.id  }

    num_bought  { rand(100) }
    created_at  { FactoryGirl.generate(:far_past) }
    
    credits     { rand(100) }
    price       { FactoryGirl.generate(:dollar_amount) }
    state       { "TODO: purchase state" }

    id          { [deal_id, credit_card_id, state].slugify }
  end
end

# module V2::Purchase
#   class DefaultSerializer
#     def self.as_json(p, opts={})
#       {
#         :id => p.slug,
#         :deal_id => p.deal.slug,
#         :user_id => p.user.try(:slug),
#         :credit_card_id => p.credit_card.try(:slug),
#         :num_bought => p.num_bought,
#         :created_at => p.created_at,
#         :credits => p.credits,
#         :price => p.price,
#         :payment_state => p.payment_state
#       }
#     end
#   end
# end
