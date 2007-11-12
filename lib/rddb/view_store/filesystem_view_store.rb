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
        File.open(File.join(basedir, name), 'w') do |f|
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
      
      # Return each view in the viewstore
      def each(&block)
        Dir.entries(basedir).each do |filename|
          if File.file?(File.join(basedir, filename))
            yield find(filename)
          end
        end
      end
      
      # List all of the views in the viewstore
      def list
        returning Array.new do |names|
          Dir.entries(basedir).each do |filename|
            if File.file?(File.join(basedir, filename))
              names << filename
            end
          end
        end
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