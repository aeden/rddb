module Rddb #:nodoc:
  # Module for materialization storage engines.
  module MaterializationStore
    
    # Base class for materialization stores. Materialization stores are used to
    # store materialized views.
    class Base
      # Find the materialization of the view.
      def find(name)
        raise_abstract_error('find')
      end
      
      # Store the materialization of the view.
      def store(view)
        raise_abstract_error('store')
      end
      
      # Delete the materialization of the named view.
      def delete(name)
        raise_abstract_error('delete')
      end
      
      # Return true if the materialization of the named view exists in storage.
      def exists?(name)
        raise_abstract_error('exists?')
      end
      
      private
      def raise_abstract_error(method)
        raise RuntimeError, "MaterializationStore::Base method is abstract, '#{method}' method not implemented"
      end
    end
  end
end

require 'rddb/materialization_store/ram_materialization_store'
require 'rddb/materialization_store/filesystem_materialization_store'
require 'rddb/materialization_store/s3_materialization_store'