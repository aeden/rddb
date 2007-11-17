# Source code for the PartitionedFileDocumentStore class definition.
require 'ftools'

module Rddb #:nodoc:
  module DocumentStore #:nodoc:
    # DocumentStore implementation that stores documents in partitioned files.
    class PartitionedFileDocumentStore < Base
      # Initialize the datastore.
      #
      # Options:
      # * <tt>:basedir</tt>: The base directory for document storage
      # * <tt>:partition_strategy</tt>: A Proc that defines partitioning
      # * <tt>:cache</tt>: Provide a cache implementation (such as a Hash)
      #   to enable caching. If not specified then caching will not be used.
      #   Note that caching only works on direct ID lookups, not on queries.
      #   Queries should use materialized views for performance.
      def initialize(options={})
        @options = options
        @options[:basedir] ||= 'data'
        load_index
      end
      
      # Find the document for the given id.
      def find(id)
        id = id.to_s
        return nil unless index[id]
        return cache[id] if cache? && cache.key?(id)
        p = index[id][:partition]
        f = open_read(p)
        f.seek(index[id][:offset])
        data = f.read(index[id][:length])
        document = Marshal.load(data)
        cache[id] = document if cache?
        document
      end
      
      # Store the document.
      def store(document)
        id = document.id.to_s
        p = partition_for(document)
        index[id] = {:partition => p}
        f = open_write(p)
        lock(p) do
          f.seek(0, IO::SEEK_END)
          index[id][:offset] = f.pos
          Marshal.dump(document, f)
          index[id][:length] = f.pos - index[id][:offset]
        end
        cache[id] = document if cache?
        document
      end
      
      # Delete the document at the given path.
      def delete(id)
        raise RuntimeError, "File datastore does not support document deletion"
      end
      
      # Return true if the document exists.
      def exists?(id)
        !index[id.to_s].nil?
      end
      
      # Trigger indexes to be stored if necessary.
      def write_indexes
        index_file = File.new(File.join(basedir, 'index'))
        index_file.flock(File::LOCK_EX)
        File.open(index_file.path, 'w') do |f|
          Marshal.dump(index, f)
        end
        index_file.flock(File::LOCK_UN)
      end
      
      # The number of documents in the datastore
      def count
        index.length
      end
      
      # Yield each document from the datastore to the given block
      def each(partition=nil, &block)
        if partition.nil?
          index.each do |id, info|
            yield find(id)
          end
        else
          f = open_read(partition)
          f.rewind
          until f.eof?
            yield Marshal.load(f)
          end
        end
      end
      
      # Yield each partition name
      def each_partition(&block)
        Dir.glob("#{basedir}/*") do |f|
          f = File.basename(f)
          next if f == 'index'
          yield f
        end
      end
      
      # Returns true
      def supports_partitioning?
        true
      end
      
      # The datastore options
      def options #:nodoc:
        @options
      end
      
      private
      def basedir
        returning options[:basedir] do |dir|
          File.makedirs(dir) unless File.directory?(dir)
        end
      end
      
      def open_write_files
        @open_write_files ||= {}
      end
      
      def open_read_files
        @open_read_files ||= {}
      end
      
      # Open the file for writing to the given partition and keep it open.
      def open_write(p)
        f = open_write_files[p]
        unless f
          f = File.open(File.join(basedir, p), 'a+')
          open_write_files[p] = f
        end
        f
      end
      
      # Open the file for reading from the given partition and keep it open.
      def open_read(p)
        f = open_read_files[p]
        unless f
          f = File.open(File.join(basedir, p))
          open_read_files[p] = f
        end
        f
      end
      
      # Get the partition name for the specified document. If no partition 
      # strategy is defined then the partition name will be 'default'
      def partition_for(document)
        if options[:partition_strategy]
          options[:partition_strategy].call(document)
        else
          'default'
        end
      end
      
      # Acquire a write lock on the specified partition and then yield to
      # the block. Upon completion of the block release the lock.
      def lock(partition, &block)
        f = File.new(File.join(basedir, partition))
        f.flock(File::LOCK_EX)
        yield
        f.flock(File::LOCK_UN)
      end
      
      def index
        @index ||= {}
      end
      
      def load_index
        index_file = File.join(basedir, 'index')
        if File.exist?(index_file)
          File.open(index_file) do |f|
            #puts "loading index"
            @index = Marshal.load(f)
            #puts "index loaded with #{@index.length} items"
          end
        end
      end
      
      # Return true if caching is enabled.
      def cache?
        !options[:cache].nil?
      end
      
      # Get the cache
      def cache
        @cache ||= options[:cache].new
      end
    end
  end
end