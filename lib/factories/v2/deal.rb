load File.join(File.dirname(__FILE__), "../sequences.rb")

FactoryGirl.define do
  factory :deal, :class => Hoodwink::Models::Deal do
    ignore do
      merchant { Factory(:merchant) }
      region   { Factory(:region)   }
    end

    merchant_name { merchant.name }
    merchant_id   { merchant.id   }

    region_name { region.name }
    region_id   { region.id   }
    
    title
    id   { title.to_s.slugify }
    type { %w[daily-deal city-sampler private-reserve on-going hot-minute daily-deal].sample }

    product_name
    
    highlights         { FactoryGirl.generate(:short_lorem)   }
    description1       { FactoryGirl.generate(:long_lorem)    }
    description2       { FactoryGirl.generate(:long_lorem)    }
    purchasable_number { FactoryGirl.generate(:big_rand)      }
    category           { FactoryGirl.generate(:category_name) }
    
    start_at
    end_at
    time_left { end_at - Time.now }
    sold_out false
    expires_at     { FactoryGirl.generate(:far_future) }
    
    shipping_address_required false
    ended false

    fine_print     { FactoryGirl.generate(:long_lorem)    }
    
    price          { FactoryGirl.generate(:dollar_amount) }
    value          { FactoryGirl.generate(:dollar_amount) }
    starting_price { FactoryGirl.generate(:dollar_amount) }

    image
    image_url      { image.gsub("xlarge.jpg", "medium.jpg") }

    locations      { FactoryGirl.generate(:addresses) }

    number_sold    { FactoryGirl.generate(:small_rand) }
    num_left       { FactoryGirl.generate(:small_rand) }
    num_available  { FactoryGirl.generate(:big_rand)   }
    tipping_point  { FactoryGirl.generate(:small_rand) }
    max_per_user   { FactoryGirl.generate(:small_rand) }

    state "TODO: deal state"

    custom_data   { FactoryGirl.generate(:long_lorem) }
    instructions  { FactoryGirl.generate(:long_lorem) }

    fulfillment_method "TODO: deal fulfillment_method"

    expiry_as_of_now { FactoryGirl.generate(:far_future) }
  end
end


# module V2::Deal
#   class DefaultSerializer
#     def self.as_json(deal, opts={})
#       {
#         :id => deal.slug,
#         :title => deal.title,
#         :type => deal.type,
#         :product_name => deal.product_name,
#         :merchant_id => deal.merchant.try(:slug),
#         :merchant_name => deal.merchant.try(:name),
#         :highlights => deal.highlights,
#         :description1 => deal.low_down,
#         :description2 => deal.situation,
#         :purchasable_number => deal.num_purchasable,
#         :category => deal.category_name,
#         :start_at => deal.start_at.try(:to_s),
#         :end_at => deal.end_at.try(:to_s),
#         :time_left => deal.time_left.try(:to_s),
#         :soldout => deal.sold_out?,
#         :expires_at => deal.expires_at,
#         :shipping_address_required => deal.sent_by_mail?,
#         :ended => deal.ended?,
#         :fine_print => deal.fine_print,
#         :price => deal.current_price,
#         :value => deal.value,
#         :starting_price => deal.price,
#         :image => deal.image,
#         :image_url => deal.image("medium"),
#         :region_id => deal.region.try(:slug),
#         :region_name => deal.region.try(:name),
#         :locations => deal.locations,
#         :number_sold => deal.num_purchased,
#         :state => deal.workflow_state,
#         :num_left => deal.num_left,
#         :num_available => deal.num_available,
#         :tipping_point => deal.tipping_point,
#         :custom_data => deal.data_mappings_with_name,
#         :instructions => deal.instructions,
#         :max_per_user => deal.max_per_user,
#         :fulfillment_method => deal.fulfillment_method,
#         :expiry_as_of_now => deal.expiry_as_of_now
#       }
#     end
#   end
# end
