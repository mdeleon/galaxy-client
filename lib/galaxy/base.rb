require 'galaxy'

module Galaxy
  # The Galaxy::Base class inherits from ActiveResource::Base and acts as the central class to store common settings for all Galaxy models.
  # Currently all Galaxy models inherit from Base.
  class Base < ActiveResource::Base
    extend Timeify

    cattr_accessor :version
    cattr_accessor :path

    self.include_root_in_json = true
    self.format = :json

    # TODO configure this
    # self.ssl_options

    def self.create!(attributes = {})
       self.new(attributes).tap { |resource| resource.save! }
    end

    def self.has_many(model)
      model = model.to_s
      class_eval(%Q[def #{model.pluralize}(params={})
                @#{model.pluralize} ||= model_for(:#{model.singularize}).find(:all, :from => "/\#{self.class.path}/#{self.to_s.demodulize.underscore.pluralize}/\#{self.id}/#{model.pluralize}.json", :params => params)
              end
        ])
    end

    def self.many_to_one(model)
      model = model.to_s.singularize
      class_eval(%Q[
        def #{model}(params={})
          @#{model} ||= model_for(:#{model}).find(:one, :from => "/\#{self.class.path}/#{model.pluralize}/\#{self.#{model}_id}.json", :params => params)
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
end
