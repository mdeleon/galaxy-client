load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :catagory, :class => Hoodwink::Models::Catagory do
    sequence(:name) {|n| "Category #{n}" }
    id          { name.slugify }
    created_at  { FactoryGirl.generate(:far_past) }
  end
end

# module V2::Category
#   class DefaultSerializer
#     def self.as_json(category, opts={})
#       {
#         :id => category.slug,
#         :name => category.name,
#         :created_at => category.created_at
#         # need slug for parent
#       }
#     end
#   end
# end
