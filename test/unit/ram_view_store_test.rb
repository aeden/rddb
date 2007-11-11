require File.dirname(__FILE__) + '/test_helper'

class RamViewStoreTest < Test::Unit::TestCase
  def test_initialize_and_options
    view_store = Rddb::ViewStore::RamViewStore.new(:option1 => 'test')
    assert_equal({:option1 => 'test'}, view_store.options)
  end
  
  def test_find_and_store
    view_store = Rddb::ViewStore::RamViewStore.new
    assert_nil view_store.find('test')
    view_store.store('test', "create_view('test')")
    assert_equal "create_view('test')", view_store.find('test')
  end
  
  def test_delete
    view_store = Rddb::ViewStore::RamViewStore.new
    view_store.store('test', "create_view('test')")
    assert_equal "create_view('test')", view_store.find('test')
    view_store.delete('test')
    assert_nil view_store.find('test')
  end
  
  def test_exists
    view_store = Rddb::ViewStore::RamViewStore.new
    assert !view_store.exists?('test')
    view_store.store('test', "create_view('test')")
    assert view_store.exists?('test')
    view_store.delete('test')
    assert !view_store.exists?('test')
  end
end