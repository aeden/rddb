module Rddb #:nodoc:
  module MaterializationStore #:nodoc:
    # Materialization store implementation that stores view data in RAM.
    class RamMaterializationStore < Base
      
      # Initialized the materialization store with the given options.
      def initialize(options={})
        @options = options
      end
      
      # Find the view.
      def find(name)
        materialized_views[name]
      end
      
      # Store the view.
      def store(view)
        if view.materialized?
          materialized_views[view.name] = view.materialized
        end
      end
      
      # Delete the view.
      def delete(name)
        materialized_views.delete(name)
      end
      
      # Return true if the view exists in storage.
      def exists?(name)
        materialized_views.key?(name)
      end
      
      protected
      # The viewstore options
      def options #:nodoc:
        @options
      end
      
      private
      def materialized_views
        @materialized_views ||= {}
      end
    end
  end
end