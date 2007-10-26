# Source file containing the Rddb::Database class definition
module Rddb #:nodoc:
  # The database.
  class Database
    # A Logger for the database.
    attr_accessor :logger
    
    # The document store.
    attr_reader :document_store
    
    # Initialize the database.
    def initialize(document_store=DocumentStore::RamDocumentStore.new)
      @document_store = document_store ||= DocumentStore::RamDocumentStore.new
      @materialization_thread = Thread.new(@document_store.dup) do |ds|
        while true do
          view = materialization_queue.pop
          logger.info "Materializing the view '#{view.name}'" if logger
          view.materialize(ds)
          logger.info "The view '#{view.name}' is now materialized" if logger
        end
      end
      @batch = false
    end
    
    # Add a document to the database. The document may either be a Hash or
    # a Rddb::Document instance.
    def <<(document)
      case document
      when Hash
        self << Document.new(document)
      when Document
        document_store.store(document)
        # TODO: this may be a bottleneck, allow index updating
        document_store.write_indexes unless @batch
        update_materialization_queue(document)
        document
      else
        raise ArgumentError, "The document must be either a Hash or a Document"
      end
    end
    
    # Batch process the given block, disabling materialization queue updating
    # and index writing until the block has completed. All views that are 
    # materialized will be refreshed upon completion of the block and any
    # document_store indexes will be written.
    def batch(&block)
      @batch = true
      yield
      views.each do |name,view|
        @materialization_queue << view if view.materialized?
      end
      document_store.write_indexes
      @batch = false
    end
    
    # Get a document by it's ID.
    def [](id)
      document_store.find(id)
    end
    
    # Return the total count of documents in the database
    def count
      document_store.count
    end
    
    # Query the named view
    def query(name)
      raise ArgumentError, "View '#{name}' does not exist." unless views.key?(name)
      views[name].query(document_store)
    end
    
    # Create the named view with the given filter code.
    # Returns the newly created view object.
    def create_view(name, options={}, &block)
      returning View.new(self, name, options, &block) do |view|
        views[name] = view
      end
    end
    
    # Refresh all materialized views.
    def refresh_views
      views.each do |name,view|
        @materialization_queue << view if view.materialized?
      end
    end
    
    def logger #:nodoc:
      unless @logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::FATAL
      end
      @logger
    end
    
    private
    # Get named views.
    def views
      @views ||= {}
    end
    
    private
    # Update the materialization queue.
    def update_materialization_queue(document)
      unless @batch
        views.each do |name, view|
          materialization_queue << view if view.should_refresh?(document)
        end
      end
    end
    
    def materialization_queue
      @materialization_queue ||= Queue.new
    end
  end
end