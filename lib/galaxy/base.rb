require 'active_support/all'
require 'httparty'
require 'galaxy'

module Galaxy
  class NotFoundError < StandardError; end
  class InternalError < StandardError; end
  class InvalidResponseError < StandardError; end

  class ValidationError < StandardError
    attr_reader :errors

    def initialize(msg, errors)
      super(msg)
      @errors = errors
    end
  end
end

module Galaxy::Base
  extend ActiveSupport::Concern

  included do
    include HTTParty

    attr_accessor :attributes

    # base_uri
    default_options[:debug_output] = Galaxy::Config.debug if Galaxy::Config.debug

    # ActiveSupport::Concern doesnt allow me to overload class methods so the only way I know
    #   how is to overload when included. Hacky, sorry...
    def self.default_options
      super.merge(
        :base_uri => Galaxy::Config.base_uri,
        :default_params => {:api_key => Galaxy::Config.api_key}
      )
    end
  end

  module ClassMethods
    def find(id)
      instance = new(:id => id)
      instance.find
      instance
    end
    alias :[] :find

    def create(attrs={})
      instance = new(attrs)
      instance.create
      instance
    end

    # helper method for hashes
    def underscore_keys(hash)
      modify_keys(hash) { |key| key.to_s.underscore.to_sym }
    end

    # helper method for hashes
    def camelize_keys(hash)
      modify_keys(hash) { |key| key.to_s.camelize(:lower).to_sym }
    end

    # helper method for hashes
    def modify_keys(hash, &blk)
      hash.inject({}) do |h,(k,v)|
        h.merge(blk.call(k) => v.is_a?(Hash) ? modify_keys(v, &blk) : v)
      end
    end
  end

  def initialize(attributes={})
    @attributes = attributes.with_indifferent_access
  end

  # Calls #{endpoint}/add
  #
  # Returns HTTParty::Response
  def create
    raise RuntimeError if attributes[:id]
    response  = self.class.post("/#{endpoint}", :body => self.class.camelize_keys(attributes))
    assert_response! response

    # TODO: raise exceptions
    digest response

    response
  end
  alias :save! :create   # make factory girl friendly

  def find
    response = self.class.get("/#{endpoint}/#{id}")
    assert_response! response

    digest response

    @attributes = HashWithIndifferentAccess.new(
      self.class.underscore_keys(response["response"][name])
    )

    response
  end

  def name
    @name ||= self.class.to_s.demodulize.downcase
  end

  def endpoint
    @endpoint ||= name.pluralize
  end

  # ensures we have a 2xx status code, otherwise, raise error.
  def assert_response!(response)
    pr = response.parsed_response
    case
    when response.code == 404
      raise Galaxy::NotFoundError, "#{pr['errorMsg'].inspect} (#{response.code})"
    when response.code == 422
      raise Galaxy::ValidationError.new("#{pr['errorMsg'].inspect} (#{response.code})", pr[name]["errors"])
    when response.code >= 500
      raise Galaxy::InternalError, "#{pr['errorMsg'].inspect} (#{response.code})"
    end
  end

  # assign attributes from response
  def digest(response)
    raise Galaxy::InvalidResponseError.new("Resource element not found in response") unless response[name]
    @attributes = HashWithIndifferentAccess.new(
      self.class.underscore_keys(response[name])
    )
  end

  def method_missing(method_symbol, *arguments) #:nodoc:
    method_name = method_symbol.to_s

    if method_name =~ /(=|\?)$/
      case $1
      when "="
        attributes[$`] = arguments.first
      when "?"
        !!attributes[$`]
      end
    else
      return attributes[method_name] if attributes.include?(method_name)
      # not set right now but we know about it
      super
    end
  end


  protected

  # Returns HTTParty::Response
  def post_action(action)
    response = self.class.post("/#{endpoint}/#{id}/#{action}")
    assert_response! response
    response
  end
end
