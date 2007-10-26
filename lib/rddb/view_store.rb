# Source code for the Rddb::ViewStore::Base class definition.
module Rddb #:nodoc:
  # Module for view stores.
  module ViewStore
    # Base class for view stores.
    class Base
      # Find the view.
      def find(name)
        raise_abstract_error('find')
      end
      
      # Store the view.
      def store(name, view_code)
        raise_abstract_error('store')
      end
      
      # Delete the view.
      def delete(name)
        raise_abstract_error('delete')
      end
      
      # Return true if the view exists in storage.
      def exists?(name)
        raise_abstract_error('exists?')
      end
      
      private
      def raise_abstract_error(method)
        raise RuntimeError, "Viewstore is abstract, '#{method}' method not implemented"
      end
    end
  end
end

require 'rddb/view_store/ram_view_store'
require 'rddb/view_store/filesystem_view_store'
require 'rddb/view_store/s3_view_store'