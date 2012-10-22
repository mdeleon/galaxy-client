require 'galaxy'

module Galaxy
  # The Galaxy::Base class inherits from ActiveResource::Base and acts as the central class to
  # store common settings for all Galaxy models. Currently all Galaxy models inherit from Base.
  class Base < ActiveResource::Base
    extend Timeify

    cattr_accessor :version
    cattr_accessor :path

    self.include_root_in_json = true
    self.format = :json

    class << self
      def raw_with_prefix(path)
        "#{prefix}#{path}"
      end
    end
    # TODO configure this
    # self.ssl_options

    def self.create!(attributes = {})
       self.new(attributes).tap { |resource| resource.save! }
    end

    def self.has_many(resource, opts={})
      resource_name = resource.to_s
      resource_path = resource_name.demodulize.underscore
      resource_type = (opts[:class].presence || resource_name).to_s.demodulize.underscore.singularize
      klass_path    = self.to_s.demodulize.underscore.pluralize
      quantity_select = opts[:select] || "all"
      resource_path = resource_path.pluralize if quantity_select == "all"

      default_params_hash_or_proc = opts[:default_params] || {}

      define_method resource_name do |params={ }|
        return unless self.id.present?

        default_params_hash = if default_params_hash_or_proc.respond_to?(:call)
                                default_params_hash_or_proc.call(self)
                              else
                                default_params_hash_or_proc
                              end

        params = params.merge(default_params_hash)

        retval = instance_variable_get("@#{resource_name}")
        unless retval
          retval = if self.attributes[resource_name.to_sym].present?
                     self.attributes[resource_name.to_sym].map { |r| model_for(resource_type.to_sym).new(r.attributes) }
                   else
                     model_for(resource_type.to_sym).find(
                       quantity_select.to_sym,
                       :from   => "/#{self.class.path}/#{klass_path}/#{self.id}/#{resource_path}.json",
                       :params => params)
                   end
          instance_variable_set("@#{resource_name}", retval)
        end
        retval
      end
    end


    def self.has_one(resource, opts={})
      has_many(resource, opts.merge(:select => 'one'))
    end

    def self.belongs_to(resource, opts={})
      resource_name = resource.to_s
      resource_key = "#{resource}_id"
      resource_type = (opts[:class].presence || resource_name).to_s.demodulize.underscore

      default_params_hash_or_proc = opts[:default_params] || {}

      define_method resource_name do |params={ }|
        default_params_hash = if default_params_hash_or_proc.respond_to?(:call)
                                default_params_hash_or_proc.call(self)
                              else
                                default_params_hash_or_proc
                              end

        params = params.merge(default_params_hash)

        retval = instance_variable_get("@#{resource_name}")
        unless retval
          retval = if self.attributes[resource_name.to_sym].present?
                     model_for(resource_type.to_sym).new(self.attributes[resource_name.to_sym].attributes)
                   elsif self.attributes[resource_key.to_sym].present?
                     model_for(resource_type.to_sym).find(self.attributes[resource_key.to_sym], :params => params)
                   else
                     raise "missing resource key #{resource_key}"
                   end
          instance_variable_set("@#{resource_name}", retval)
        end
        retval
      end
    end

    def self.model_key
      self.to_s.demodulize
    end

    # This method takes a galaxy client model name and returns the corresponding model class
    # The returned model class is either a model class defined by the application (which is derived from
    # Galaxy client's class), or the Galaxy client's class itself.  For example, model_for(:user)
    # will trigger this method to look for a User class in the global scope.  If such a class is found
    # and it is extended from Galaxy client's User class, then the global scope ::User class is returned.
    # Otherwise, Galaxy::User class is returned.  If Galaxy::User cannot be found either, a NameError exception
    # will be raised.
    def model_for(class_name)
      name = class_name.to_s.split('::').last.camelize
      galaxy_model_class = "Galaxy::#{name}".constantize
      # use derived model class if we can find one
      (c = "::#{name}".constantize) && c < galaxy_model_class && c || galaxy_model_class
      rescue NameError => e
        galaxy_model_class || raise(e)
    end

    def self.model_for
      name = to_s.split('::').last.camelize
      galaxy_model_class = self
      # use derived model class if we can find one
      (c = "::#{name}".constantize) && c < galaxy_model_class && c || galaxy_model_class
      rescue NameError => e
        galaxy_model_class || raise(e)
    end
  end

  def self.resource_path(model)
    model.demodulize.underscore.pluralize
  end
end
