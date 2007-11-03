require File.dirname(__FILE__) + '/../test_helper'

class FilesystemMaterializationStoreTest < Test::Unit::TestCase
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
    
    view = Rddb::View.new(database, name) do |document, args|
      document.name
    end.materialize_if do
      true
    end
    
    [view, database]
  end
  
  def materialization_store
    Rddb::MaterializationStore::FilesystemMaterializationStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/materializations'
    )
  end
end