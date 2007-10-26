# Gratuitous borrowing from Josh Carter's Simple MapReduce article:
# http://multipart-mixed.com/software/simple_mapreduce_in_ruby.html
#
# Copyright (c) 2006 Josh Carter <josh@multipart-mixed.com>

module Rddb #:nodoc:
  class Worker #:nodoc:
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
  
  class WorkerTask #:nodoc:
    attr_reader :task_id, :partition, :process, :datastore_class, :datastore_options

    def initialize(task_id, partition, process, datastore_class, datastore_options)
      @task_id = task_id
      @partition = partition
      @process = process
      @datastore_class = datastore_class
      @datastore_options = datastore_options
    end

    def run
      returning Array.new do |results|
        datastore = datastore_class.new(datastore_options)
        datastore.each(partition) do |document|
          results << process.call(document)
        end
      end
    end
  end
end