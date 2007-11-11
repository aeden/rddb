require File.dirname(__FILE__) + '/test_helper'

class FilesystemViewStoreTest < Test::Unit::TestCase
  def test_initialize_and_options
    basedir = File.dirname(__FILE__) + '/../tmp/views'
    view_store = Rddb::ViewStore::FilesystemViewStore.new(:basedir => basedir)
    assert_equal({:basedir => basedir}, view_store.options)
  end
  
  def test_find_and_store
    assert_nil view_store.find('test')
    view_store.store('test', "create_view('test')")
    assert_equal "create_view('test')", view_store.find('test')
  end
  
  def test_delete
    view_store.store('test', "create_view('test')")
    assert_equal "create_view('test')", view_store.find('test')
    view_store.delete('test')
    assert_nil view_store.find('test')
  end
  
  def test_exists
    assert !view_store.exists?('test')
    view_store.store('test', "create_view('test')")
    assert view_store.exists?('test')
    view_store.delete('test')
    assert !view_store.exists?('test')
  end
  
  protected
  def view_store(options={})
    @view_store ||= Rddb::ViewStore::FilesystemViewStore.new({
      :basedir => File.dirname(__FILE__) + '/../tmp/views'
    }.merge(options))
  end
end