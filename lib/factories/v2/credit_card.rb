load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :credit_card, :class => Hoodwink::Models::CreditCard do
    ignore do
      user    { Factory(:user)    }
    end

    user_id   { user.id }
    
    type       { FactoryGirl.generate(:cc_type)   }
    number     { FactoryGirl.generate(:cc_number) }
    is_primary { FactoryGirl.generate(:boolean)   }
    deleted    false

    id          { [user_id, type].slugify }
  end
end

# module V2::CreditCard
#   class DefaultSerializer
#     def self.as_json(cc, opts={})
#       {
#         :user_id => cc.user.slug,
#         :type => cc.type,
#         :number => cc.number,
#         :primary => cc.is_primary,
#         :deleted => cc.is_deleted,
#         :id => cc.slug
#       }
#     end
#   end
# end
