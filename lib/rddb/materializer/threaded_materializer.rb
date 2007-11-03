module Rddb
  module Materializer
    class ThreadedMaterializer
      # Reader for the database
      attr_reader :database #:nodoc:
    
      # Initialize the materializer with the given database.
      def initialize(database)
        @database = database
        @materialization_thread = Thread.new(database.document_store.dup) do |ds|
          while true do
            view = materialization_queue.pop
            logger.info "Materializing the view '#{view.name}'" if logger
            view.materialize(ds)
            logger.info "The view '#{view.name}' is now materialized" if logger
          end
        end
      end
    
      # Callback that is invoked when a document is added to the database.
      def document_added(document)
        update_materialization_queue(document)
      end
    
      # Refresh all materialized views.
      def refresh_views
        database.views.each do |name,view|
          @materialization_queue << view if view.materialized?
        end
      end
    
      private
      # Accessor for the database
      def database
        @database
      end
      
      # Accessor for the logger
      def logger
        database.logger
      end
    
      # Update the materialization queue.
      def update_materialization_queue(document)
        unless database.batch?
          database.views.each do |name, view|
            materialization_queue << view if view.should_refresh?(document)
          end
        end
      end
    
      # Accessor for the materialization queue.
      def materialization_queue
        @materialization_queue ||= Queue.new
      end
    end
  end
end