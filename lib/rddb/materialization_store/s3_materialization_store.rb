module Rddb #:nodoc:
  module MaterializationStore #:nodoc:
    # Materialization store implementation that stores view data in S3.
    class S3MaterializationStore < Base
      include AWS::S3
      
      # Initialized the view store with the given bucket name and options.
      def initialize(bucket_name, options={})
        AWS::S3::Base.establish_connection!(options[:s3])
        @bucket_name = bucket_name
        @options = options
        @options[:basedir] ||= 'materializations'
      end
      
      # The bucket name
      def bucket_name
        returning @bucket_name do |name|
          begin
            Bucket.create(name)
          rescue => e
            #puts "Error creating bucket: #{e}"
          end
        end
      end
      
      # Find the view.
      def find(name)
        d = S3Object.value(File.join(basedir, name), bucket_name)
        Marshal.load(d)
      end
      
      # Store the view.
      def store(view)
        if view.materialized?
          S3Object.store(File.join(basedir, view.name), Marshal.dump(view.materialized), bucket_name)
        end
      end
      
      # Delete the view.
      def delete(name)
        S3Object.delete(File.join(basedir, name), bucket_name)
      end
      
      # Return true if the view exists in storage.
      def exists?(name)
        S3Object.exists?(File.join(basedir, name), bucket_name)
      end
      
      # The viewstore options
      def options #:nodoc:
        @options
      end
      
      private
      def basedir
        options[:basedir]
      end
    end
  end
end