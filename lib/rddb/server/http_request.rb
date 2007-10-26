module Rddb #:nodoc:
  module Server #:nodoc:
    # Extension module that is mixed into the Mongrel HttpRequest object to add
    # functionality and helper methods
    module HttpRequest #:nodoc:
      # Return the request path
      def path
        params['PATH_INFO']
      end

      # Return the request host
      def host
        params['HTTP_HOST'].split(":")[0]
      end

      # Return the request port
      def port
        params['HTTP_HOST'].split(":")[1] || '80'
      end

      # Return the HTTP request method
      def method
        params['REQUEST_METHOD']
      end

      # Return the content type
      def content_type
        params['HTTP_CONTENT_TYPE']
      end

      # Return a Hash of headers. Headers are params beginning with HTTP_
      def headers
        returning Hash.new do |h|
          params.each do |k,v|
            if k =~ /^HTTP_(.*)/
              hkey = $1
              h[hkey.downcase.gsub(/_/, ' ').gsub(/\b([a-z])/) { $1.capitalize }.gsub(/ /, '-')] = v
            end
          end
        end
      end
    end
  end
end