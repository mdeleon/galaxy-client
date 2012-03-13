load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :sent_email, :class => Hoodwink::Models::SentEmail do
    ignore do
      to_user    { Factory(:user)    }
      from_user  { Factory(:user)    }
    end

    to_user_id   { to_user.id }
    from_user_id { from_user.id }
    
    to           { FactoryGirl.generate(:email) }
  end
end

# module V2::SentEmail
#   class DefaultSerializer
#     def self.as_json(email, opts={})
#       {
#         :to => email.to || "",
#         :to_user_id => email.to_user && email.to_user.slug || nil,
#         :from_user_id => email.from_user && email.from_user.slug || nil
#       }
#     end
#   end
# end
