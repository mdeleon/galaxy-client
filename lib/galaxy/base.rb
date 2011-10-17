require 'galaxy'

module Galaxy
  class Base < ActiveResource::Base
    self.include_root_in_json = true
    self.format = :json
  end
end
