require File.dirname(__FILE__) + '/test_helper'

class ThreadedMaterializerTest < Test::Unit::TestCase
  def test_initialization
    materializer = Rddb::Materializer::ThreadedMaterializer.new(database)
  end
  
  def test_threaded_materializer_is_default
    database = Rddb::Database.new
    assert_equal Rddb::Materializer::ThreadedMaterializer, database.materializer.class
  end
  
  def test_refresh_views
    assert_nothing_raised do
      v = database.views['test']
      assert_nil v.materialized
      materializer = Rddb::Materializer::ThreadedMaterializer.new(database)
      materializer.refresh_views
      assert_equal 2, v.materialized.length
    end
  end
  
  def test_document_added
    assert_equal Rddb::Materializer::ThreadedMaterializer, database.materializer.class
    v = database.views['test']
    assert_nil v.materialized
    database << {:name => 'Chris'}
    assert_equal 3, v.materialized.length
    database << {:name => 'Jane'}
    assert_equal 4, v.materialized.length
  end
  
  protected
  def database(options={})
    @database ||= returning Rddb::Database.new(options) do |database|
      database << {:name => 'Bob'}
      database << {:name => 'Jim'}
      database.create_view('test') do |document, args|
        document
      end.materialize_if do |document|
        true
      end
    end
  end
end