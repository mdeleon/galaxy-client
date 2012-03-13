load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :region, :class => Hoodwink::Models::Region do
    name   { FactoryGirl.generate(:city) }
    active true
    timezone
    selectable true

    id     { name.slugify }
  end
end

# module V2::Region
#   class DefaultSerializer
#     def self.as_json(r, opts={})
#       {
#         :id => r.slug,
#         :name => r.name,
#         :active => r.is_active,
#         :timezone => r.timezone,
#         :selectable => r.selectable?
#       }
#     end
#   end
# end
