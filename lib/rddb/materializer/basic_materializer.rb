# Source code the for the single threaded Materializer.

module Rddb #:nodoc:
  module Materializer #:nodoc:
    # A single threaded materializer.
    class BasicMaterializer
      # The database
      attr_reader :database

      # Initialize the materializer.
      def initialize(database, materialization_store)
        @database = database
        @materialization_store = materialization_store
      end
      
      # Materialize the specified view.
      def materialize(view)
        
      end
    end
  end
end