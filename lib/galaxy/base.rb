require 'galaxy'

module Galaxy
  class Base < ActiveResource::Base
    cattr_accessor :api_key
    self.include_root_in_json = true

    private

    # Patch this method to add api_key
    # https://github.com/rails/rails/blob/b8bb5f44c8ba02786ed42d04f66641f236ef42c3/activeresource/lib/active_resource/connection.rb#L109
    def request(method, path, *arguments)
      result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
        payload[:method]      = method

        # append api_key depending on if there is already a query string
        uri = URI.parse("#{site.scheme}://#{site.host}:#{site.port}#{path}")
        if uri.query.blank?
          uri.query = "api_key=#{self.api_key}"
        else
          uri.query += "&api_key=#{self.api_key}"
        end

        payload[:request_uri] = uri.to_s
        payload[:result]      = http.send(method, path, *arguments)
      end
      handle_response(result)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(e.message)
    end
  end
end
