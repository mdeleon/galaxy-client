load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :coupon, :class => Hoodwink::Models::Coupon do
    ignore do
      purchase    { Factory(:purchase)    }
      deal        { Factory(:deal)        }
      credit_card { Factory(:credit_card) }
    end

    purchase_id     { purchase.id     }
    deal_id         { deal.id         }
    credit_card_id  { credit_card.id  }
    
    expires_at  { FactoryGirl.generate(:far_future) }
    redeemed_at { FactoryGirl.generate(:near_past) }
    created_at  { FactoryGirl.generate(:far_past) }
    state       { ["valid", "expired", "active"].sample }
    barcode     { "TODO: coupon barcode" }
    
    id          { "%05i" % rand(10000) }
  end
end

# module V2::Coupon
#   class DefaultSerializer
#     def self.as_json(coupon, opts={})
#       {
#         :id => coupon.slug,
#         :purchase_id => coupon.purchase.slug,
#         :deal_id => coupon.deal.slug,
#         :credit_card_id => coupon.purchase.credit_card.try(:slug),
#         #:user_id => coupon.user.slug,
#         :expires_at => coupon.expires_at,
#         :redeemed_at => coupon.redeemed_at,
#         :state => coupon.state,
#         :barcode => coupon.displayed_barcode,
#         :created_at => coupon.created_at
#       }
#     end
#   end
# end
