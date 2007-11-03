# Source code the for the single threaded Materializer.

module Rddb #:nodoc:
  module Materializer #:nodoc:
    # A single threaded materializer.
    class BasicMaterializer
      # The database
      attr_reader :database

      # Initialize the materializer.
      def initialize(database)
        @database = database
      end
      
      # Materialize the specified view.
      def materialize(view)
        logger.info "Materializing the view '#{view.name}'" if logger
        view.materialize(database.document_store) if view.materialized?
        logger.info "The view '#{view.name}' is now materialized" if logger
      end
      
      def document_added(document)
        database.views.each do |name, view|
          materialize(view) if view.should_refresh?(document)
        end
      end
      
      # Refresh all materialized views.
      def refresh_views
        database.views.each do |name, view|
          materialize(view)
        end
      end
      
      private
      def logger #:nodoc:
        database.logger
      end
    end
  end
end