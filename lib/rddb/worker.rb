# Gratuitous borrowing from Josh Carter's Simple MapReduce article:
# http://multipart-mixed.com/software/simple_mapreduce_in_ruby.html
#
# Copyright (c) 2006 Josh Carter <josh@multipart-mixed.com>

module Rddb #:nodoc:
  # Module that contains worker classes for various view materializers.
  module Worker 
    class WorkerTask #:nodoc:
      attr_reader :task_id, :partition, :process, :view_name, :document_store, :args

      # Initialize the worker task.
      def initialize(task_id, partition, process, view_name, document_store, args={})
        @task_id = task_id
        @partition = partition
        @process = process
        @view_name = view_name
        @document_store = document_store
        @args = args
      end

      # Run the worker task.
      def run
        returning Array.new do |results|
          document_store.each(partition) do |document|
            results << process.call(document, args)
          end
          results.compact!
        end
      end
    end
  end
end

require 'rddb/worker/local_worker'
require 'rddb/worker/ec2_worker'
require 'rddb/worker/rinda_worker'