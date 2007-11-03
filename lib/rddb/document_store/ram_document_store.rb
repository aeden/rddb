# Source code for the RamDocumentStore class definition.
module Rddb #:nodoc:
  module DocumentStore #:nodoc:
    # DocumentStore implementation that stores documents in a Hash in memory.
    class RamDocumentStore < Base
      # Initialize the datastore.
      def initialize(options={})
        @options = options
      end
      
      # Find the document for the given id.
      def find(id)
        documents[id.to_s]
      end
      
      # Store the document.
      def store(document)
        documents[document.id.to_s] = document
      end
      
      # Delete the document at the given path.
      def delete(id)
        documents.delete(id.to_s)
      end
      
      # Return true if the document exists.
      def exists?(id)
        documents.key?(id.to_s)
      end
      
      # The number of documents in the datastore
      def count
        documents.length
      end
      
      # Yield each document from the datastore to the given block
      def each(partition=nil, &block)
        documents.each do |id, document|
          yield document
        end
      end
      
      # Yield each partition name
      def each_partition(&block)
        yield 'default'
      end
      
      # Never duplicate the RAM store.
      def dup #:nodoc:
        self
      end

      # The datastore options
      def options #:nodoc:
        @options
      end
      
      private
      def documents
        @documents ||= {}
      end
    end
  end
end