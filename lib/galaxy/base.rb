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
      resource      = resource.to_s
      klass_path    = self.to_s.demodulize.underscore.pluralize
      resource_path = (opts[:class].to_s.presence || resource).pluralize
      resource_type = resource_path.singularize

      default_params = opts.delete(:default_params) || {}
      default_params = default_params.call if default_params.respond_to?(:call)

      class_eval( %Q[
        def #{resource}(params={})
          params = params.merge(#{default_params})

          @#{resource} ||= if self.attributes.has_key?(:#{resource})
            self.#{resource_path}.map{ |r| model_for(:#{resource_type}).new(r) }
          else
            model_for(:#{resource_type}).find(
              :all,
              :from => "/\#{self.class.path}/#{klass_path}/\#{self.id}/#{resource_path}.json",
              :params => params)
          end
        end
      ])
    end

    def self.belongs_to(resource, opts={})
      resource = resource.to_s
      resource_key = "#{resource}_id"
      resource_type = (opts[:class].presence || resource).to_s.demodulize.underscore

      default_params = opts.delete(:default_params) || {}
      default_params.call if default_params.respond_to?(:call)

      class_eval(%Q[
        def #{resource}(params={})
          params = params.merge(#{default_params})
          @#{resource} ||= if self.attributes.has_key?(:#{resource})
            model_for(:#{resource_type}).new(self.#{resource})
          elsif self.respond_to?(:#{resource_key})
            model_for(:#{resource_type}).find(#{resource_key}, :params => params)
          else
            puts 'what?!'
            model_for(:#{resource_type}).new(get(:#{resource}), :params => params)
          end
        end
      ])
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
