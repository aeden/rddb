module Rddb
  # Materializer handles the materialization of views.
  class Materializer
    # Reader for the database
    attr_reader :database #:nodoc:
    
    def initialize(database)
      @database = database
      @database.database_listeners << self
      @materialization_thread = Thread.new(database.document_store.dup) do |ds|
        while true do
          view = materialization_queue.pop
          logger.info "Materializing the view '#{view.name}'" if logger
          view.materialize(ds)
          logger.info "The view '#{view.name}' is now materialized" if logger
        end
      end
    end
    
    def document_added(document)
      update_materialization_queue(document)
    end
    
    def refresh_views
      database.views.each do |name,view|
        @materialization_queue << view if view.materialized?
      end
    end
    
    private
    def database
      @database
    end
    
    # Update the materialization queue.
    def update_materialization_queue(document)
      unless database.batch?
        database.views.each do |name, view|
          materialization_queue << view if view.should_refresh?(document)
        end
      end
    end
    
    def materialization_queue
      @materialization_queue ||= Queue.new
    end
  end
end