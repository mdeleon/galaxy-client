require 'active_resource'

# patch active resource.  see:
# https://github.com/rails/rails/issues/2908
# https://github.com/rails/rails/pull/3046/files
module ActiveResource
  class Errors < ActiveModel::Errors
    def from_hash(messages, save_cache = false)
      clear unless save_cache

      messages.each do |(key,errors)|
        errors.each do |error|
          if @base.attributes.keys.include?(key)
            add key, error
          else
            self[:base] << "#{key.humanize} #{error}"
          end
        end
      end
    end

    # Grabs errors from a json response.
    def from_json(json, save_cache = false)
      hash = ActiveSupport::JSON.decode(json)['errors'] || {} rescue {}
      from_hash hash, save_cache
    end
  end
end
