module Rddb #:nodoc:
  module Worker #:nodoc:
    # Instances of the Ec2Worker class are started up on N EC2 instances
    # and listen for notifications over SQS to begin processing.
    class Ec2Worker
      # The queue name
      attr_reader :queue_name
      
      # Initialize the worker with the specified queue name.
      def initialize(queue_name)
        @queue_name = queue_name
      end
      
      # Run the worker
      def run
        Daemons.run_proc('worker', :multiple => true, :log_output => true) do
          queue = SQS.get_queue(queue_name)
          while true do
            queue.peek_message do |message|
              puts "message received: #{message.inspect}"
            end
          end
        end
      end
    end
  end
end