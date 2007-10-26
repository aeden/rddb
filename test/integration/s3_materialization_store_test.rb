require File.dirname(__FILE__) + '/test_helper'

class S3MaterializationStoreTest < Test::Unit::TestCase
  include S3Config
  def test_store_and_find
    view, database = create_view_and_database
    view.materialize(database.document_store)
    materialization_store.store(view)
    assert materialization_store.exists?(view.name)
  end
  
  def test_delete
    view, database = create_view_and_database
    view.materialize(database.document_store)
    materialization_store.store(view)
    assert materialization_store.exists?(view.name)
    materialization_store.delete(view.name)
    assert !materialization_store.exists?(view.name)
  end
  
  protected
  def create_view_and_database(name = 'test')
    database = Rddb::Database.new
    database << {:name => 'Joe'}
    database << {:name => 'Jim'}
    
    view = Rddb::View.new(database, name) do |document|
      document.name
    end.materialize_if do
      true
    end
    
    [view, database]
  end
  
  def materialization_store
    Rddb::MaterializationStore::S3MaterializationStore.new('rddb-test', :s3 => s3_config)
  end
end