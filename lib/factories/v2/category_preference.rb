load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :catagory_preference, :class => Hoodwink::Models::CatagoryPreference do
    ignore do
      user { Factory(:user) }
      category { Factory(:category) }
    end

    user_id     { user.id     }
    category_id { category.id }
    created_at  { FactoryGirl.generate(:far_past) }

    id          { name.slugify }
  end
end

# module V2::CategoryPreference
#   class DefaultSerializer
#     def self.as_json(category_preference, opts={})
#       {
#         :id => category_preference.slug,
#         :user_id => category_preference.user.slug,
#         :category_id => category_preference.category.slug,
#         :created_at => category_preference.category.created_at
#       }
#     end
#   end
# end
