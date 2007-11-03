# Source file containing the Rddb::View class definition
module Rddb #:nodoc:
  # A view on the database. Views are used to express queries. Views use Ruby 
  # blocks to process the documents in the document store and produce 
  # responses. Views can be materialized to improve performance.
  class View
    # Get the name of the view.
    attr_reader :name
    
    # Initialize the view instance with the given name and the block
    # used to map the documents to the view result set.
    # 
    # Options:
    # * <tt>:materialization_store</tt>: A MaterializationStore instance, defaults to 
    #   FilesystemMaterializationStore.
    def initialize(database, name, options={}, &block)
      @database = database
      @name = name
      @block = block
      
      @materialization_store = options[:materialization_store] if options[:materialization_store]
      @distributed = options[:distributed]
    end
    
    # Query the view
    def query(document_store, args) #:nodoc:
      # Load the data if the view should be materialized and if the 
      # materialized data cache is nil. Args and materialized views
      # are not yet supported.
      if args.empty?
        load_data if materialized? && materialized.nil?
      
        if materialized
          database.logger.info "Using materialized view"
          return materialized
        end
      end
      
      # If materialization is required and this point is reached, it means that
      # the materialization cache was not yet loaded. Raise an error which can
      # be caught allowing the method to be retried.
      raise ViewNotYetMaterialized if @require_materialization
      
      do_query(document_store, args)
    end
    
    # Materialize the view
    def materialize(document_store)
      #puts "querying for materialization"
      @materialized = do_query(document_store)
      materialization_store.store(self)
    end
    
    # Provide a block that is used to reduce the result set upon completion
    # of the mapping.
    def reduce_with(&block)
      @reduce_with = block
      return self
    end
    
    # Define a block that is used to determine if the view requires updating.
    # This is only used when a view is materialized.
    def materialize_if(&block)
      @materialize_check = block
      return self
    end
    
    # Indicate that materialization is required before responding to queries.
    def require_materialization
      @require_materialization = true
    end
    
    # Return true if the view is a materialized view.
    def materialized?
      !@materialize_check.nil?
    end
    
    # Return true if the view requires an update for the specified document.
    def should_refresh?(document)
      materialized? && @materialize_check.call(document)
    end
    
    # Get the materialized data.
    def materialized #:nodoc:
      @materialized
    end
    
    # Return true if the view querying is distributed.
    def distributed?
      @distributed
    end
    
    protected
    # Interal query
    def do_query(document_store, args={})
      # map
      results = do_map(document_store, args)
      # reduce (if necessary)
      @reduce_with.nil? ? results : @reduce_with.call(results)
    end
    
    def do_map(document_store, args={}) #:nodoc:
      tasks = []
      document_store.each_partition do |partition|
        tasks << Worker::WorkerTask.new(
          partition, partition, @block, document_store, args
        )
      end
      
      worker_class = Worker::LocalWorker
      worker_class = Worker::RindaWorker if distributed?
      worker_class.process(tasks)
    end
    
    # Get the database instance
    def database
      @database
    end
    
    # Get the materialization store instance, defaulting to a RamMaterializationStore.
    def materialization_store
      @materialization_store ||= MaterializationStore::RamMaterializationStore.new
    end
    
    private
    # Load the materialized data
    def load_data
      if materialization_store.exists?(name)
        database.logger.info("Loading data for '#{name}' from materialization store")
        @materialized = materialization_store.find(name)
      end
    end
    
  end
end