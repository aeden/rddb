# Gratuitous borrowing from Josh Carter's Simple MapReduce article:
# http://multipart-mixed.com/software/simple_mapreduce_in_ruby.html
#
# Copyright (c) 2006 Josh Carter <josh@multipart-mixed.com>

module Rddb #:nodoc:
  # Module that contains worker classes for various view materializers.
  module Worker 
    class WorkerTask #:nodoc:
      attr_reader :task_id, :partition, :process, :datastore_class, :datastore_options

      # Initialize the worker task.
      def initialize(task_id, partition, process, datastore_class, datastore_options)
        @task_id = task_id
        @partition = partition
        @process = process
        @datastore_class = datastore_class
        @datastore_options = datastore_options
      end

      # Run the worker task.
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
end

require 'rddb/worker/ec2_worker'
require 'rddb/worker/rinda_worker'