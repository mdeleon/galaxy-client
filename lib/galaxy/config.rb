module Galaxy
  class Config
    class << self
      def api_key(val=nil)
        @api_key = val if val
        @api_key
      end

      # Render HTTP request/response to a stream
      def debug(stream=nil)
        @debug = stream if stream
        @debug
      end

      # http://homerun.offerengine.com/api/v2
      def base_uri(val=nil)
        @base_uri = val if val
        @base_uri
      end
    end
  end
end
