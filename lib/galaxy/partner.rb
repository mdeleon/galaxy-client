module Galaxy
  class Partner < Galaxy::Base
    def config_hash
      # amazingly, I see no way to do this via ActiveResource
      active_resource_to_hash(config)
    end

    protected
    def active_resource_to_hash(resource)
      hash = HashWithIndifferentAccess.new

      resource.attributes.each_pair do |key, value|
        hash[key] = if value.is_a?(ActiveResource::Base)
                      active_resource_to_hash(value)
                    else
                      value
                    end
      end

      hash
    end
  end
end