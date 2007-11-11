module Rddb #:nodoc:
  module Server #:nodoc:
    # ViewHandler is a mongrel HTTP handler that is used for retrieving and
    # storing view descriptions via a REST interface.
    class ViewHandler < Mongrel::HttpHandler
      
      # The underlying document store
      attr_accessor :view_store
      
      # Initialize the handler with the given view store.
      def initialize(view_store)
        @view_store = view_store
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
        view_name = request.path[0..-1]
        begin
          if view_name.empty?
            response.start(403) do |head, out|
              out.write("The root path is not allowed.\n")
              return
            end
          end
          view = view_store.find(view_name)
          if view
            response.start(200) do |head, out|
              #head['Content-Type'] = ''
              out.write(view)
            end
          else
            response.start(404) do |head, out|
              out.write("The view #{view_name} was not found.\n")
            end
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      # Implementation of the POST method (will always return 403).
      def post(request, response)
        begin
          response.start(403) do |head, out|
            out.write("The POST method is not allowed.\n")
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      # Implementation of the PUT method. This method will return 200 if 
      # the view already exists and is updated, or 201 if the view does not
      # exist and is created.
      def put(request, response)
        view_name = request.path[0..-1]
        begin
          if view_name.empty?
            response.start(403) do |head, out|
              out.write("The root path is not allowed.\n")
              return
            end
          end
          
          view_body = request.body.read
          
          if view_store.exists?(view_name)
            view_store.store(view_name, view_body)
            response.start(200) do |head, out|
              head['Location'] = "/#{view_name}"
              out.write("The view was updated.\n")
            end
          else
            view_store.store(view_name, view_body)
            response.start(201) do |head, out|
              head['Location'] = "/#{view_name}"
              out.write("The view was created.\n")
            end
          end
        rescue => e
          server_error(e, request, response)
        end
      end
    
      # Implementation of the DELETE method.
      def delete(request, response)
        view_name = request.path[0..-1]
        begin
           if view_store.exists?(view_name)
             view_store.delete(view_name)
             response.start(200) do |head, out|
               out.write("The view #{view_name} was deleted.\n")
             end
           else
             response.start(404) do |head, out|
               out.write("The view #{view_name} does not exist.\n")
             end
           end
        rescue => e
          server_error(e, request, response)
        end
      end
      
      private
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