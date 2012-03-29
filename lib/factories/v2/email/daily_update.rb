load File.join(File.dirname(__FILE__), "../../sequences.rb")

FactoryGirl.define do
  factory :daily_update, :class => Hoodwink::Models::DailyUpdate do
    ignore do
      to_user    { Factory(:user)    }
      from_user  { Factory(:user)    }
    end

    to_user_id   { to_user.id }
    from_user_id { from_user.id }
    
    to           { Faker::Internet.email   }
  end
end

# module V2::Email::DailyUpdate
#   class DefaultSerializer
#     def self.as_json(email, opts={})
#       {
#         :to => email.to || "",
#         :to_user_id => email.to_user && email.to_user.slug || nil,
#         :from_user_id => nil
#       }
#     end
#   end
# end
