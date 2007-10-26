require 'ftools'

module Rddb #:nodoc:
  module ViewStore #:nodoc:
    # View store implementation that stores view data in the file system.
    class FilesystemViewStore < Base
      
      # Initialized the view store with the given options.
      #
      # Options:
      # * <tt>:basedir</tt>: The base directory
      def initialize(options={})
        @options = options
        @options[:basedir] ||= 'views'
      end
      
      # Find the view.
      def find(name)
        if exists?(name)
          view_code = File.read(File.join(basedir, name))
        end
      end
      
      # Store the view.
      def store(name, view_code)
        File.open(File.join(basedir, view.name), 'w') do |f|
          f << view_code
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
      
      protected
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