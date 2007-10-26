# Source file containing the Rddb::View class definition
module Rddb #:nodoc:
  # A view on the database. Views are used to express queries. Views use Ruby blocks
  # to process the documents in the document store and produce responses. Views can
  # be materialized to improve performance.
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
    def query(document_store) #:nodoc:
      # Load the data if the view should be materialized and if the 
      # materialized data cache is nil.
      load_data if materialized? && materialized.nil?
      
      if materialized
        database.logger.info "Using materialized view"
        return materialized
      end
      
      # If materialization is required and this point is reached, it means that
      # the materialization cache was not yet loaded. Raise an error which can
      # be caught allowing the method to be retried.
      raise ViewNotYetMaterialized if @require_materialization
      
      do_query(document_store)
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
    def do_query(document_store)
      results = []
      # map
      if distributed?
        results = do_distributed_query(document_store)
      else
        results = do_local_query(document_store)
      end
      
      # reduce (if necessary)
      if @reduce_with
        @reduce_with.call(results)
      else
        results
      end
    end
    
    def do_local_query(document_store) #:nodoc:
      database.logger.info "Executing local view query"
      returning Array.new do |results|
        document_store.each_partition do |partition|
          if document_store.supports_partitioning?
            database.logger.debug "Reading from partition #{partition}"
          end
          document_store.each(partition) do |document|
            result = @block.call(document)
            results << result if result # nils not included in the result set
          end
        end
      end
    end
    
    def do_distributed_query(document_store) #:nodoc:
      database.logger.info "Executing distributed view query"
      tasks = []
      document_store.each_partition do |partition|
        puts "distributing partition '#{partition}'"
        tasks << WorkerTask.new(partition, partition, @block, document_store.class, document_store.options)
      end
      
      tasks.each do |task|
        tuple_space.write(['task', DRb.uri, task])
      end
      
      results = []
      tasks.each do |task|
        puts "taking result from tuple space for partition '#{task.partition}'"
        tuple = tuple_space.take(['result', DRb.uri, task.partition, nil])
        results << tuple[3]
      end
      
      results.flatten
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
    
    # Get the tuple space for distributed processing
    def tuple_space
      unless @tuple_space 
        DRb.start_service
        ring_server = Rinda::RingFinger.primary

        ts = ring_server.read([:name, :TupleSpace, nil, nil])[2]
        @tuple_space = Rinda::TupleSpaceProxy.new ts
      end
      @tuple_space
    end
    
  end
end