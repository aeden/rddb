# Gratuitous borrowing from Josh Carter's Simple MapReduce article:
# http://multipart-mixed.com/software/simple_mapreduce_in_ruby.html
#
# Copyright (c) 2006 Josh Carter <josh@multipart-mixed.com>

module Rddb #:nodoc: 
  module Worker #:nodoc:
    # Worker that pulls tasks from a Rinda tuple space.
    class RindaWorker
      # Initialize with the specified options
      def initialize(options={})
      end
      
      # Run the worker
      def run
        Daemons.run_proc('worker', :multiple => true, :log_output => true) do
          begin
            DRb.start_service
            ring_server = Rinda::RingFinger.primary

            ts = ring_server.read([:name, :TupleSpace, nil, nil])[2]
            ts = Rinda::TupleSpaceProxy.new ts

            # Wait for tasks, pull them off and run them
            puts "executing worker loop"
            loop do
              begin
                tuple = ts.take(['task', nil, nil])
                task = tuple[2]
                puts "processing partition #{task.partition}"
                puts "using datastore #{task.datastore_class}"

                if task.respond_to?(:run)
                  result = task.run
                  puts "writing result to tuple space"
                  ts.write(['result', tuple[1], task.task_id, result])
                else
                  puts "Task is not a task: #{task.class}"
                end
              rescue Errno::ECONNREFUSED
                puts "Ring server has gone down, stopping worker."
                break
              rescue => e
                puts "An error occured: #{e}"
                puts e.backtrace.join("\n")
              end
            end
          rescue RuntimeError
            puts "Ring server not found, are you sure the ring server is running?"
          end
        end
      end
    end
  end
end