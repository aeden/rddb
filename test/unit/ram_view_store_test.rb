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
  
  def test_each
    view_store = Rddb::ViewStore::RamViewStore.new
    view_store.store('test1', 'test1 code')
    view_store.store('test2', 'test2 code')
    assert_equal 2, view_store.to_a.length
    assert_equal ['test1 code', 'test2 code'], view_store.to_a.sort
  end
  
  def test_list
    view_store = Rddb::ViewStore::RamViewStore.new
    view_store.store('test1', 'test1 code')
    view_store.store('test2', 'test2 code')
    assert_equal ['test1', 'test2'], view_store.list.sort
  end
end