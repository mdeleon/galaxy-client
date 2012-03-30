require "active_resource"
require "galaxy/version"
require "galaxy/base"

require "galaxy/address"
require "galaxy/coupon"
require "galaxy/credit_card"
require "galaxy/category"
require "galaxy/category_preference"
require "galaxy/saved_deal"
require "galaxy/card_link"
require "galaxy/location"
require "galaxy/deal"
require "galaxy/email"
require "galaxy/merchant"
require "galaxy/purchase"
require "galaxy/region"
require "galaxy/subscription"
require "galaxy/user"
require "galaxy/reset_token"

require "activeresource/validations"

module GalaxyClient
  FACTORY_DIRS_V2 = [File.join(File.dirname(__FILE__), "factories/v2")]
end
