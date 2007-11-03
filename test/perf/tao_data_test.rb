require File.dirname(__FILE__) + '/test_helper'

class TaoDataTest < Test::Unit::TestCase
  def test_tao_in_ram
    db = create_db_and_views
    load_database(db)
    db.refresh_views
    do_assertions(db)
  end
  
  def test_tao_in_partitioned_file
    f = File.dirname(__FILE__) + '/../tmp/tao_in_partitioned_file'
    already_loaded = File.exist?(f)
    
    ps = Proc.new { |document| document.year }
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :partition_strategy => ps, :basedir => f
    )
    
    db = create_db_and_views(ds)
    load_database(db) unless already_loaded
    db.refresh_views
    do_assertions(db)
  end
  
  def test_tao_in_single_file
    f = File.dirname(__FILE__) + '/../tmp/tao_in_single_file'
    already_loaded = File.exist?(f)
    
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(:basedir => f)
    db = create_db_and_views(ds)
    load_database(db) unless already_loaded
    db.refresh_views
    do_assertions(db)
  end
  
  def test_tao_with_cache
    # TODO: implement test
  end
  
  def test_tao
    f = File.dirname(__FILE__) + '/../tmp/tao'
    already_loaded = File.exist?(f)
    
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(:basedir => f)
    db = create_db_and_views(ds, false)
    load_database(db) unless already_loaded
    
    puts "Querying: average air temp"
    query_time = Benchmark.realtime do
      result = db.query('average air temp')
      assert_equal 23, result
      puts "Average air temp: #{result}c"
    end
    puts "#{query_time} sec to query"
    
    puts "Querying: average air temp"
    query_time = Benchmark.realtime do
      result = db.query('average air temp')
      assert_equal 23, result
      puts "Average air temp: #{result}c"
    end
    puts "#{query_time} sec to query"
  end
  
  def test_tao_with_distributed
    f = File.dirname(__FILE__) + '/../tmp/tao'
    already_loaded = File.exist?(f)
    
    ps = Proc.new { |document| document.year }
    
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => f, :partition_strategy => ps
    )

    db = Rddb::Database.new(ds)
    db.logger = Logger.new(STDOUT)
    db.logger.level = Logger::DEBUG
  
    db.create_view('average air temp', :distributed => true) do |document, args|
      document.air_temp
    end.reduce_with do |results|
      results.inject { |memo,value| memo + value } / results.length
    end
    
    load_database(db) unless already_loaded
    
    puts "Querying: average air temp"
    query_time = Benchmark.realtime do
      result = db.query('average air temp')
      assert_equal 23, result
      puts "Average air temp: #{result}c"
    end
    puts "#{query_time} sec to query"
  end
  
  def create_db_and_views(ds=nil, materialize=true)
    returning Rddb::Database.new(:document_store => ds) do |db|
      db.logger = Logger.new(STDOUT)
      db.logger.level = Logger::DEBUG
    
      db.create_view('average air temp') do |document, args|
        document.air_temp
      end.reduce_with do |results|
        results.inject { |memo,value| memo + value } / results.length
      end
      
      if materialize
        db.create_view('average air temp materialized') do |document, args|
          document.air_temp
        end.reduce_with do |results|
          results.inject { |memo,value| memo + value } / results.length
        end.materialize_if do |document|
          true
        end.require_materialization
      end
    end
  end
  
  def load_database(db)
    puts "Loading data"
    load_time = Benchmark.realtime do
      db.batch do 
        Zlib::GzipReader.open(File.dirname(__FILE__) + '/tao-all2.dat.gz').each_line do |line|
          obs, year, month, day, date, latitude, longitude, zon_winds, mer_winds, 
          humidity, air_temp, sea_surface_temp = line.split
          db << {
            :obs => obs,
            :year => year,
            :month => month,
            :day => day,
            :date => date,
            :latitude => latitude.to_f,
            :longitude => longitude.to_f,
            :zon_winds => zon_winds.to_i,
            :mer_winds => mer_winds.to_i,
            :humidity => humidity.to_i,
            :air_temp => air_temp.to_i,
            :sea_surface_temp => sea_surface_temp.to_i
          }
        end
      end
    end
    puts "#{load_time} sec to load"
  end
  
  def do_assertions(db, expects_materialized=true)
    assert_equal 178080, db.count
    
    puts "Querying: average air temp"
    query_time = Benchmark.realtime do
      result = db.query('average air temp')
      assert_equal 23, result
      puts "Average air temp: #{result}c"
    end
    puts "#{query_time} sec to query"
    
    if expects_materialized
      begin
        query_materialized(db)
      rescue Rddb::ViewNotYetMaterialized
        puts "View is not yet materialized"
        sleep 5
        retry
      end
    end
  end
  
  def query_materialized(db)
    puts "Querying: average air temp materialized"
    query_time = Benchmark.realtime do
      result = db.query('average air temp materialized')
      assert_equal 23, result
      puts "Average air temp: #{result}c"
    end
    puts "#{query_time} sec to query materialized view"
  end
end