# Source file containing the Rddb::DocumentStore::Base class definition.
module Rddb #:nodoc:
  # Module for Rddb document storage engines.
  module DocumentStore
    # Base class for document storage engines.
    class Base
      include Enumerable
      
      # Find the document.
      def find(id)
        raise_abstract_error('find')
      end
      
      # Store the document.
      def store(document)
        raise_abstract_error('store')
      end
      
      # Delete the document.
      def delete(id)
        raise_abstract_error('delete')
      end
      
      # Return true if the document exists.
      def exists?(id)
        raise_abstract_error('exists?')
      end
      
      # The number of documents in the data store
      def count
        raise_abstract_error('count')
      end
      
      # Yield each document from the data store to the given block. You may 
      # specify the partition to limit the data extraction to a single
      # partition.
      def each(partition=nil, &block)
        raise_abstract_error('each')
      end
      
      # Yield each partition name
      def each_partition(&block)
        raise_abstract_error('each_partition')
      end
      
      # Return true if the datastore supports partitioning
      def supports_partitioning?
        false
      end
      
      # Trigger indexes to be stored if necessary. Default implementation is
      # a no-op.
      def write_indexes
      end

      private
      def raise_abstract_error(method)
        raise RuntimeError, "DocumentStore is abstract, '#{method}' method not implemented"
      end
    end
  end
end

require 'rddb/document_store/ram_document_store'
require 'rddb/document_store/partitioned_file_document_store'
require 'rddb/document_store/s3_document_store'