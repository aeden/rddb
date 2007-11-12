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
  
  def test_each
    clear_directory
    view_store.store('test1', 'test1')
    view_store.store('test2', 'test2')
    assert_equal 2, view_store.to_a.length
    assert_equal ['test1', 'test2'], view_store.to_a.sort
  end
  
  def test_list
    clear_directory
    view_store.store('test1', 'test1 code')
    view_store.store('test2', 'test2 code')
    assert_equal ['test1', 'test2'], view_store.list.sort
  end
  
  protected
  def view_store(options={})
    @view_store ||= Rddb::ViewStore::FilesystemViewStore.new({
      :basedir => File.dirname(__FILE__) + '/../tmp/views'
    }.merge(options))
  end
  
  def clear_directory
    basedir = view_store.options[:basedir]
    Dir.entries(basedir).each do |filename|
      f = File.join(basedir, filename)
      File.delete(f) if File.file?(f)
    end
  end
end