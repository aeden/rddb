module Rddb #:nodoc:
  module Worker #:nodoc:
    # Instances of the LocalWorker class are executed in the current
    # application.
    class LocalWorker      
      # Initialize the worker with the specified options
      def initialize(options={})
        @options = options
      end
      
      # Process the specified tasks.
      def self.process(tasks)
        returning Array.new do |results|
          # What I'd really like to do here is just flatten then results, 
          # however only to a certain depth (i.e. I only want to flatten 
          # the first layer of the array, not records that are returned
          # as arrays)
          tasks.each { |t| t.run.each { |r| results << r }}
        end
      end
      
      # Run the worker service.
      def run
        # no op
      end
    end
  end
end