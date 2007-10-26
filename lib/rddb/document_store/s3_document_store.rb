# Source file containing the S3DocumentStore class definition.
module Rddb #:nodoc:
  module DocumentStore #:nodoc:
    # DocumentStore that stores documents in Amazon S3.
    class S3DocumentStore < Base
      include AWS::S3
      include Enumerable
      
      # Initialize the datastore.
      #
      # Options:
      # * <tt>:basedir</tt>: The base directory for data storage
      # * <tt>:partition_strategy</tt>: A Proc that defines partitioning
      # * <tt>:cache</tt>: Provide a cache implementation (such as a Hash)
      #   to enable caching. If not specified then caching will not be used.
      #   Note that caching only works on direct ID lookups, not on queries.
      #   Queries should use materialized views for performance.
      def initialize(bucket_name, options={})
        AWS::S3::Base.establish_connection!(options[:s3])
        @bucket_name = bucket_name
        @options = options
        @options[:basedir] ||= 'data'
        load_index
      end
      
      # Get the bucket name.
      def bucket_name
        returning @bucket_name do |name|
          begin
            Bucket.create(name)
          rescue => e
            #puts "Error creating bucket: #{e}"
          end
        end
      end
      
      # Find the document for the given id.
      def find(id)
        id = id.to_s
        return nil unless index[id]
        return cache[id] if cache? && cache.key?(id)
        p = index[id][:partition]
        v = S3Object.value(File.join(basedir, p), bucket_name)
        data = v[index[id][:offset]..(index[id][:offset] + index[id][:length])]
        #puts "Data: #{data}"
        document = Marshal.load(data)
        cache[id] = document if cache?
        document
      end
      
      # Store the document.
      def store(document)
        id = document.id.to_s
        p = partition_for(document)
        index[id] = {:partition => p}
        if S3Object.exists?(File.join(basedir, p), bucket_name)
          v = S3Object.value(File.join(basedir, p), bucket_name)
          index[id][:offset] = v.length
          s = Marshal.dump(document)
          #puts "Marshalled value: #{s}"
          index[id][:length] = s.length
          S3Object.store(File.join(basedir, p), v + s, bucket_name)
        else
          s = Marshal.dump(document)
          #puts "Marshalled value: #{s}"
          S3Object.store(File.join(basedir, p), s, bucket_name)
          index[id][:offset] = 0
          index[id][:length] = s.length
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
        S3Object.store(File.join(basedir, 'index'),  Marshal.dump(index), bucket_name)
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
          S3Object.stream(File.join(basedir, p), bucket_name) do |f|
            until f.eof?
              yield Marshal.load(f)
            end
          end
        end
      end
      
      # Yield each partition name
      def each_partition(&block)
        Bucket.objects(bucket_name, :prefix => basedir) do |o|
          f = File.basename(o.key)
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
        options[:basedir]
      end
      
      def partition_for(document)
        if options[:partition_strategy]
          options[:partition_strategy].call(document)
        else
          'default'
        end
      end
      
      def index
        @index ||= {}
      end
      
      def load_index
        index_file = File.join(basedir, 'index')
        if S3Object.exists?(index_file, bucket_name)
          S3Object.stream(index_file, bucket_name) do |f|
            puts "loading index"
            @index = Marshal.load(f)
            puts "index loaded with #{@index.length} items"
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