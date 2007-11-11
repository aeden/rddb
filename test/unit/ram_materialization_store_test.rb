require File.dirname(__FILE__) + '/../test_helper'

class RamViewstoreTest < Test::Unit::TestCase
  def test_initialize
    options = {:test => 'test'}
    materialization_store = Rddb::MaterializationStore::RamMaterializationStore.new(options)
    assert_equal({:test => 'test'}, materialization_store.options)
  end
  
  def test_store_and_find
    materialization_store = Rddb::MaterializationStore::RamMaterializationStore.new
    assert_nil materialization_store.find('test')
    view = create_view
    assert view.materialized?
    view.materialize(document_store)
    materialization_store.store(view)
    assert_not_nil materialization_store.find('test')
  end
  
  protected
  def document_store
    Rddb::DocumentStore::RamDocumentStore.new
  end
  
  def create_view
    Rddb::View.new(:database, 'test') do |document, args|
      document
    end.materialize_if do |document|
      true
    end
  end
end