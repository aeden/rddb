require File.dirname(__FILE__) + '/../test_helper'

class RamDocumentStoreTest < Test::Unit::TestCase
  def test_store_and_find
    document = create_document
    ds = Rddb::DocumentStore::RamDocumentStore.new
    ds.store(document)
    assert ds.exists?(document.id)
    assert_equal document, ds.find(document.id)
    assert_equal 1, ds.count
  end
  
  def test_delete
    document = create_document
    ds = Rddb::DocumentStore::RamDocumentStore.new
    ds.store(document)
    assert ds.exists?(document.id)
    assert_equal 1, ds.count
    ds.delete(document.id)
    assert !ds.exists?(document.id)
    assert_equal 0, ds.count
  end
  
  protected
  def create_document(options={})
    Rddb::Document.new({:name => 'test'}.merge(options))
  end
end