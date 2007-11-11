require 'ftools'

module Rddb #:nodoc:
  module MaterializationStore #:nodoc:
    # Materialization store implementation that stores view data in the file system.
    class FilesystemMaterializationStore < Base
      
      # Initialized the materialization store with the given options.
      #
      # Options:
      # * <tt>:basedir</tt>: The base directory
      def initialize(options={})
        @options = options
        @options[:basedir] ||= 'materializations'
      end
      
      # Find the view.
      def find(name)
        if exists?(name)
          File.open(File.join(basedir, name)) do |f|
            Marshal.load(f)
          end
        end
      end
      
      # Store the view.
      def store(view)
        if view.materialized?
          File.open(File.join(basedir, view.name), 'w') do |f|
            Marshal.dump(view.materialized, f)
          end
        end
      end
      
      # Delete the view.
      def delete(name)
        File.delete(File.join(basedir, name)) if exists?(name)
      end
      
      # Return true if the view exists in storage.
      def exists?(name)
        File.exist?(File.join(basedir, name))
      end
      
      # The viewstore options
      def options #:nodoc:
        @options
      end
      
      private
      def basedir
        returning options[:basedir] do |dir|
          File.makedirs(dir) unless File.directory?(dir)
        end
      end
    end
  end
end