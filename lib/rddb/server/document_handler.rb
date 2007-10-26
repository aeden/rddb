module Rddb #:nodoc:
  module Server #:nodoc:
    # DocumentHandler is a mongrel HTTP handler that is used for retrieving and
    # storing documents via a REST interface. Note that only the GET and POST methods
    # are implemented.
    class DocumentHandler < Mongrel::HttpHandler
      
      # The underlying document store
      attr_accessor :document_store
      
      # Initialize the handler with the given document store.
      def initialize(document_store)
        @document_store = document_store
      end
    
      # Process the HTTP request
      def process(request, response)
        #puts "Received #{request.method} request of type #{request.content_type} for #{request.host}:#{request.port}#{request.path}"
        case request.method
        when 'GET'
          get(request, response)
        when 'POST'
          post(request, response)
        when 'PUT'
          put(request, response)
        when 'DELETE'
          delete(request, response)
        else
          response.start(405) do |head, out|
            out.write("Unsupported method: #{request.method}.\n")
          end
        end
      end
  
      protected
      # Implementation of the GET method.
      def get(request, response)
        document_id = request.path[0..-1]
        puts "Getting #{document_id}"
        begin
          if document_id.nil? || document_id.empty?
            response.start(403) do |head, out|
              out.write("The root path is not allowed.\n")
              return
            end
          end
          document = document_store.find(document_id)
          if document
            puts "Found document, returning 200 with document data"
            response.start(200) do |head, out|
              head['Content-Type'] = 'application/x-url-form-encoded'
              out.write(document.to_wire)
            end
          else
            response.start(404) do |head, out|
              out.write("The document #{document_id} was not found.\n")
            end
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      # Implementation of the POST method.
      def post(request, response)
        document = to_document(request.body.read)
        begin
          document = document_store.store(document)
          response.start(201) do |head, out|
            head['Location'] = "/documents/#{document.id}"
            out.write("The document was created.\n")
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      # Implementation of the PUT method (will always return 403).
      def put(request, response)
        begin
          response.start(403) do |head, out|
            out.write("The PUT method is not allowed.\n")
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      # Implementation of the DELETE method (will always return 403).
      def delete(request, response)
        begin
           response.start(403) do |head, out|
            out.write("The DELETE method is not allowed.\n")
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      private
      def to_document(str)
        returning Document.new do |document|
          CGI.unescape(str).split(/&/).each do |pair|
            name, value = pair.split(/=/)
            document[name.to_sym] = value
          end
        end
      end
      
      # Respond with a 500 server error.
      def server_error(error, request, response)
        puts "A server error occurred: #{error.message} (type:#{error.class})"
        puts error.backtrace.join("\n")
        response.start(500) do |head, out|
          out.write("A server error occured: #{error.message}.\n")
        end
      end
      
    end
  end
end