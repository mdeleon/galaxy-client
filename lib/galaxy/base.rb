require 'galaxy'

module Galaxy
  # The Galaxy::Base class inherits from ActiveResource::Base and acts as the central class to store common settings for all Galaxy models.
  # Currently all Galaxy models inherit from Base.
  class Base < ActiveResource::Base

    cattr_accessor :version
    cattr_accessor :path

    self.include_root_in_json = true
    self.format = :json

    # TODO configure this
    # self.ssl_options 
  end
end
