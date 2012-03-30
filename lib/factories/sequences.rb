require 'ext/string'
require 'ext/array'

# This file is loaded from factory files, and re-loaded on each
# request. Protect from "double-define error". Maybe a global that is
# unset when sequences are cleared would work better. A require does
# not get reloaded on subsequent page requests...
FactoryGirl.define do

  sequence(:id)

  sequence(:boolean)       { [true, false].sample }

  sequence(:short_lorem)   { Faker::Lorem.sentence }
  sequence(:long_lorem)    { Faker::Lorem.paragraph }

  sequence(:small_rand)    { 10 + rand(10) }
  sequence(:medium_rand)   { 10 + rand(100) }
  sequence(:big_rand)      { 10 + rand(1000) }

  sequence(:near_past)     { (5 + rand(24*5)).hours.ago }
  sequence(:near_future)   { (5 + rand(24*5)).hours.from_now }
  sequence(:far_past)      { (30 + rand(100)).days.ago }
  sequence(:far_future)    { (30 + rand(100)).days.from_now }

  sequence(:start_at)      { FactoryGirl.generate(:near_past) }
  sequence(:end_at)        { FactoryGirl.generate(:near_future) }

  sequence(:dollar_amount) { ((5 + rand) * 30).to_f }

  sequence(:timezone)      { ActiveSupport::TimeZone::MAPPING.values.sample }

  sequence(:city)          { Faker::Address.city }
  sequence(:title)         { Faker::Company.catch_phrase.titleize.gsub(/\//, "") }

  sequence(:product_name)  { Faker::Company.bs.titleize.gsub(/\//, "") }
  sequence(:company_name)  { Faker::Company.name.gsub(/\//, "") }

  sequence(:url)           { Faker::Internet.url }
  sequence(:website)       { Faker::Internet.url }

  sequence(:email)         { [Faker::Internet.free_email, Faker::Internet.email].sample }

  sequence(:address)       { [:street_address, :city, :us_state_abbr, :zip].map{|s| Faker::Address.send(s)}.join(', ') }
  sequence(:addresses)     { (0..rand(5)).map{ FactoryGirl.generate(:address) } } 

  sequence(:phone_number)  { Faker::PhoneNumber.phone_number }
  sequence(:phone_numbers) { (0..rand(5)).map{ FactoryGirl.generate(:phone_number) } } 

  sequence(:category_name) { %w[Home Garden Automotive Dining Theater Entertainment Software].sample }

  sequence(:cc_type)       { %w[AMEX VISA MC DISCOVER DINERSCLUB].sample }
  sequence(:cc_number)     { 4.times.map{"%04d" % rand(9999)}.join("-") }

  sequence(:image) do |i| 
    images = %w[
      ugassets/deal/images/0/0/0551d492/xlarge.jpg
      ugassets/deal/images/0/0/1212b4f6/xlarge.jpg
      ugassets/deal/images/0/0/137445bf/xlarge.jpg
      ugassets/deal/images/0/0/1651ddc9/xlarge.jpg
      ugassets/deal/images/0/0/170e8669/xlarge.jpg
      ugassets/deal/images/0/0/17e508f8/xlarge.jpg
      ugassets/deal/images/0/0/1870555b/xlarge.jpg
      ugassets/deal/images/0/0/1a4d64af/xlarge.jpg
      ugassets/deal/images/0/0/1ed6803d/xlarge.jpg
      ugassets/deal/images/0/0/235062e3/xlarge.jpg
      ugassets/deal/images/0/0/2a657ba8/xlarge.jpg
      ugassets/deal/images/0/0/37a53376/xlarge.jpg
      ugassets/deal/images/0/0/3dd60b24/xlarge.jpg
      ugassets/deal/images/0/0/3fef676d/xlarge.jpg
      ugassets/deal/images/0/0/5324defb/xlarge.jpg
      ugassets/deal/images/0/0/6eff5d4e/xlarge.jpg
      ugassets/deal/images/0/0/7991ebfa/xlarge.jpg
      ugassets/deal/images/0/0/7a5a2da5/xlarge.jpg
      ugassets/deal/images/0/0/80a4b330/xlarge.jpg
      ugassets/deal/images/0/0/8561b323/xlarge.jpg
      ugassets/deal/images/0/0/88d8d8d1/xlarge.jpg
      ugassets/deal/images/0/0/8bf7381c/xlarge.jpg
      ugassets/deal/images/0/0/8f0c5a93/xlarge.jpg
      ugassets/deal/images/0/0/92d304f9/xlarge.jpg
    ]
    "http://d2x9dz1etb1m98.cloudfront.net/%s" % images[i % images.length]
  end

end if FactoryGirl.sequences.to_a.empty?

# * Faker::Name.name => "Christophe Bartell"
# * Faker::Internet.email => "kirsten.greenholt@corkeryfisher.info"
#
# ------------
# Address Fakes
# ------------
# city   city_prefix   city_suffix   secondary_address   street_address  
# street_name   street_suffix   uk_country   uk_county   uk_postcode   us_state  
# us_state_abbr   zip_code   country
#
# ------------
# Internet Fakes
# -------------
# domain_name   domain_suffix   domain_word   email   free_email   user_name  
#
# ------------
# PhoneNumber Fakes
# -------------
# phone_number  
#
# ------------
# Name Fakes
# ----------
# first_name   last_name   name   prefix   suffix  
#
# ------------
# Company Fakes
# -------------
# bs   catch_phrase   name   suffix  
#
# ------------
# Lorem Fakes
# -----------
# paragraph   paragraphs   sentence   sentences   words
