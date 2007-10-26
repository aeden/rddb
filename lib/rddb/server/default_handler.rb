module Rddb
  module Server
    class DefaultHandler < Mongrel::HttpHandler
      # Process the HTTP request
      def process(request, response)
        puts "Received #{request.method} request of type #{request.content_type} for #{request.host}:#{request.port}#{request.path}"
        response.start(200) do |head,out|
          out.write("Nothing")
        end
      end
    end
  end
end