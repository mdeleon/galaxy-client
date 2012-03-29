load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :reset_token, :class => Hoodwink::Models::ResetToken do
    ignore do
      user    { Factory(:user)    }
    end

    user_id     { user.id     }

    id          { [user_id].slugify }
  end
end

# module V2::ResetToken
#   class DefaultSerializer
#     def self.as_json(token, opts={})
#       {
#         :id => token.slug,
#         :user_id => token.user.slug
#       }
#     end
#   end
# end
