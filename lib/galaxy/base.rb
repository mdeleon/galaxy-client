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

      init_default_association_params(resource, opts)

      class_eval( %Q[
        def #{resource_name}(params={})
          return unless self.id.present?
          params = params.merge(default_association_params_for(:#{resource_name}))

          @#{resource_name} ||= if self.attributes[:#{resource_name}].present?
            self.attributes[:#{resource_name}].map{|r| model_for(:#{resource_type}).new(r.attributes)}
          else
            model_for(:#{resource_type}).find(
              :#{quantity_select},
              :from => "/\#{self.class.path}/#{klass_path}/\#{self.id}/#{resource_path}.json",
              :params => params)
          end
        end
      ])
    end

    def self.has_one(resource, opts={})
      has_many(resource, opts.merge(:select => 'one'))
    end

    def self.belongs_to(resource, opts={})
      resource_name = resource.to_s
      resource_key = "#{resource}_id"
      resource_type = (opts[:class].presence || resource_name).to_s.demodulize.underscore
      init_default_association_params(resource, opts)

      class_eval(%Q[
        def #{resource_name}(params={})
          return unless self.id.present?
          params = params.merge(default_association_params_for(:#{resource_name}))

          @#{resource_name} ||= if self.attributes[:#{resource_name}].present?
            model_for(:#{resource_type}).new(self.attributes[:#{resource_name}].attributes)
          elsif self.attributes[:#{resource_key}].present?
            model_for(:#{resource_type}).find(#{resource_key}, :params => params)
          else
            raise "missing resource key #{resource_key}"
          end
        end
      ])
    end

    def self.model_key
      self.to_s.demodulize
    end

    def self.init_default_association_params(resource, opts)
      @@default_association_params ||= {}; @@default_association_params[model_key] ||= {}
      @@default_association_params[self.to_s.demodulize][resource.to_sym] = opts.delete(:default_params) || {}
    end

    def default_association_params_for(resource_name)
      param = @@default_association_params[self.class.model_key][resource_name.to_sym]
      param.respond_to?(:call) ?  param.call(self) : param
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
