require 'test/unit'
require 'fileutils'
require 'pp'
require 'benchmark'

require File.dirname(__FILE__) + '/../../lib/rddb'

module PerfHelpers
  def do_assertions(db, expects_materialized=true)
    assert_equal 178080, db.count
    begin
      puts "Querying: average air temp materialized"
      query_time = Benchmark.realtime do
        result = db.query('average air temp materialized')
        assert_equal 23, result
        puts "Average air temp: #{result}c"
      end
      puts "#{query_time} sec to query materialized view"
    rescue Rddb::ViewNotYetMaterialized
      puts "View is not yet materialized"
      sleep 5
      retry
    end
  end
end