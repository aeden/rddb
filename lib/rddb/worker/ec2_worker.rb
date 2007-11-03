module Rddb #:nodoc:
  module Worker #:nodoc:
    # Instances of the Ec2Worker class are started up on N EC2 instances
    # and listen for notifications over SQS to begin processing.
    class Ec2Worker
      # The queue name
      attr_reader :queue_name
      
      # Initialize the worker with the specified options
      #
      # Options:
      # * <tt>:sqs</tt>: The SQS configuration options, including:
      # ** <tt>:queue_name</tt>: The queue name
      # ** <tt>:access_key_id</tt>: The access key ID
      # ** <tt>:secret_access_key</tt>: The secret access key
      def initialize(options={})
        @options = options
        @queue_name = options[:sqs][:queue_name] || 'rddb_queue'
        
        SQS.access_key_id = options[:sqs][:credentials][:access_key_id]
        SQS.secret_access_key = options[:sqs][:credentials][:secret_access_key]
      end
      
      # Process the tasks with the worker.
      def self.process(tasks)
        q = queue
        tasks.each do |task|
          q.send_message(create_message(task))
        end
      end
      
      # Run the worker
      def run
        Daemons.run_proc('worker', :multiple => true, :log_output => true) do
          q = Ec2Worker.queue
          while true do
            q.peek_message do |message|
              puts "message received: #{message.inspect}"
            end
          end
        end
      end
      
      #private
      def self.create_message(task)
        Builder::XmlMarkup.new.message { |x|
          x.task_id(task.task_id)
          x.partition(task.partition)
          x.view_name(task.view_name)
          x.document_store(task.document_store.class.name)
          task.args.sort { |a, b| a[0].to_s <=> b[0].to_s }.each do |name, value|
            x.arg {
              x.name(name.to_s)
              x.value(value.to_s)
            }
          end
        }
      end
      
      def self.queue
        begin
          SQS.get_queue(options[:sqs][:queue_name])
        rescue SQS::UnavailableQueue
          SQS.create_queue(options[:sqs][:queue_name])
        end
      end
    end
  end
end