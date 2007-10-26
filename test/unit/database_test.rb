require File.dirname(__FILE__) + '/../test_helper'

class DatabaseTest < Test::Unit::TestCase
  def test_append_document
    database = Rddb::Database.new
    doc = database << {:name => 'John', :income => 35000} 
    assert database.count == 1
    assert_not_nil doc
    assert_not_nil database[doc.id]
    assert_equal doc, database[doc.id]
    database << Rddb::Document.new(:name => 'Bob', :income => 40000)
    assert database.count == 2
  end
  
  def test_append_invalid_document_type_raises_error
    database = Rddb::Database.new
    assert_raise ArgumentError do
      database << 'foo'
    end
  end
  
  def test_batch
    database = Rddb::Database.new
    database.create_view('SELECT ALL') do |document|
      document
    end
    assert_nothing_raised do
      database.batch do 
        database << {:a => 'x', :b => 0}
      end
    end
  end
  
  def test_refresh_views
    database = Rddb::Database.new
    database.create_view('SELECT ALL') do |document|
      document
    end
    assert_nothing_raised do
      database.refresh_views
    end
  end
  
  def test_nonexistent_view_raises_error
    assert_raise ArgumentError do
      database = create_database
      database.query('foo')
    end
  end
  
  def test_simple_map_view
    database = create_database
    database.create_view('names') do |document|
      document.name
    end
    assert_equal ['Bob','Jim','John'], database.query('names').sort
  end
  
  def test_map_reduce_view_to_sum
    database = create_database
    database.create_view('total income') do |document|
      document.income
    end.reduce_with do |results|
      results.inject { |memo,value| memo + value }
    end
    assert_equal 112000, database.query('total income')
  end
  
  def test_map_reduce_view_to_average
    database = create_database
    database.create_view('average income') do |document|
      document.income
    end.reduce_with do |results|
      results.inject { |memo,value| memo + value } / results.length
    end
    assert_equal 37333, database.query('average income')
  end
  
  def test_map_reduce_view_with_grouping
    database = create_database
   
    database.create_view('total income by profession') do |document|
      [document.profession, document.income]
    end.reduce_with do |results|
      returning Hash.new do |reduced|
        results.each do |result|
          reduced[result[0]] ||= 0
          reduced[result[0]] += result[1]
        end
      end
    end
    
    results = database.query('total income by profession')
    assert_equal 77000, results['Plumber']
    assert_equal 35000, results['Carpenter']
  end
  
  def test_map_reduce_view_average_with_grouping
    database = create_database
   
    database.create_view('average income by profession') do |document|
      [document.profession, document.income]
    end.reduce_with do |results|
      reduced = {}
      counts = {}
      results.each do |result|
        reduced[result[0]] ||= 0
        reduced[result[0]] += result[1]
        counts[result[0]] ||= 0
        counts[result[0]] += 1
      end
      reduced.each do |k,v|
        reduced[k] = v / counts[k]
      end
    end
    
    results = database.query('average income by profession')
    assert_equal 38500, results['Plumber']
    assert_equal 35000, results['Carpenter']
  end
  
  def test_ordered
    database = create_database
    
    database.create_view('sorted by income') do |document|
      {
        :name => document.name,
        :income => document.income,
        :profession => document.profession
      }
    end.reduce_with do |results|
      results.sort { |a,b| a[:income] <=> b[:income] }
    end
    
    results = database.query('sorted by income')
    assert_equal [
      {:income=>35000, :profession=>"Carpenter", :name=>"John"},
      {:income=>37000, :profession=>"Plumber", :name=>"Jim"},
      {:income=>40000, :profession=>"Plumber", :name=>"Bob"}
    ], results
  end
  
  def test_distinct_ordering
    database = create_database
    
    database.create_view('distinct professions in descending order') do |document|
      document.profession
    end.reduce_with do |results|
      reduced = []
      results.each do |result|
        reduced << result unless reduced.include?(result)
      end
      reduced.sort.reverse
    end
    
    results = database.query('distinct professions in descending order')
    assert_equal ['Plumber','Carpenter'], results
  end
  
  def test_materialized_view
    database = create_database
    database.logger = Logger.new('test.log')
    database.logger.level = Logger::INFO
    
    database.create_view('names') do |document|
      document.name
    end.materialize_if do |document|
      document.attribute?(:name)
    end
    database << {:name => 'Jane', :income => 32000, :profession => 'Carpenter'}
    assert_equal ['Bob','Jane','Jim','John'], database.query('names').sort
  end
  
  def test_materialized_view_with_reduce
    database = create_database
    database.logger = Logger.new('test.log')
    database.logger.level = Logger::INFO
    
    database.create_view('names') do |document|
      document.name
    end.reduce_with do |results|
      results.sort
    end.materialize_if do |document|
      document.attribute?(:name)
    end
    database << {:name => 'Jane', :income => 32000, :profession => 'Carpenter'}
    assert_equal ['Bob','Jane','Jim','John'], database.query('names')
  end
  
  def test_view_with_duplicates
    database = create_database_extended
    database << {:name => 'John', :income => 38000, :profession => 'Trim Carpenter', 
      :date => Date.parse('2007/03/20')
    }
    
    database.create_view('sorted by income') do |document|
      {
        :name => document.name,
        :income => document.income,
        :profession => document.profession,
        :date => document.date
      }
    end.reduce_with do |results|
      names = {}
      results.each do |result|
        unless names[result[:name]] && names[result[:name]][:date] > result[:date]
          names[result[:name]] = result
        end
      end
      results = names.values.sort { |a,b| a[:income] <=> b[:income] }
      results.each { |result| result[:date] = result[:date].to_s }
      results
    end
    
    results = database.query('sorted by income')
    assert_equal [
      {:income=>37000, :profession=>"Plumber", :name=>"Jim", :date => "2005-01-24"},
      {:income=>38000, :profession=>"Trim Carpenter", :name=>"John", :date => '2007-03-20'},
      {:income=>40000, :profession=>"Plumber", :name=>"Bob", :date => "2006-11-02"}
    ], results
  end
  
  protected
  def create_database
    database = Rddb::Database.new
    database << {:name => 'John', :income => 35000, :profession => 'Carpenter'}
    database << {:name => 'Bob', :income => 40000, :profession => 'Plumber'}
    database << {:name => 'Jim', :income => 37000, :profession => 'Plumber'}
    database
  end
  
  def create_database_extended
    returning Rddb::Database.new do |db|
      db << {:name => 'John', :income => 35000, :profession => 'Carpenter', 
        :date => Date.parse('2006/10/10')
      }
      db << {:name => 'Bob', :income => 40000, :profession => 'Plumber', 
        :date => Date.parse('2006/11/02')
      }
      db << {:name => 'Jim', :income => 37000, :profession => 'Plumber', 
        :date => Date.parse('2005/01/24')
      }
    end
  end
end