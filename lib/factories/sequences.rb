require 'ext/string'

# This file is loaded from factory files, and re-loaded on each
# request. Protect from "double-define error". Maybe a global that is
# unset when sequences are cleared would work better. A require does
# not get reloaded on subsequent page requests...
FactoryGirl.define do

  sequence(:id)

  sequence(:boolean)       { [true, false].sample }

  sequence(:short_lorem)   { Faker::Lorem.sentence }
  sequence(:long_lorem)    { Faker::Lorem.paragraph }

  sequence(:small_rand)    { 3 + rand(10) }
  sequence(:big_rand)      { 10 + rand(500) }

  sequence(:near_past)     { (5 + rand(24*5)).hours.ago }
  sequence(:near_future)   { (5 + rand(24*5)).hours.from_now }
  sequence(:far_past)      { (30 + rand(100)).days.ago }
  sequence(:far_future)    { (30 + rand(100)).days.from_now }

  sequence(:start_at)      { Factory.generate(:near_past) }
  sequence(:end_at)        { Factory.generate(:near_future) }
  sequence(:expires_at)    { Factory.generate(:far_future) }

  sequence(:dollar_amount) { ((10 + rand) * 300).to_f }

  sequence(:timezone)      { ActiveSupport::TimeZone::MAPPING.values.sample }

  sequence(:city)          { Faker::Address.city }
  sequence(:title)         { Faker::Company.catch_phrase.titleize }

  sequence(:product_name)  { Faker::Company.bs.titleize }
  sequence(:company_name)  { Faker::Company.name }

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
