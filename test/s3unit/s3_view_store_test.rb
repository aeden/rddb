require File.dirname(__FILE__) + '/test_helper'

class S3ViewStoreTest < Test::Unit::TestCase
  include AWS::S3
  include S3Config
  
  def test_initialize_and_bucket_name
    bucket_name = 'rddb_test'
    view_store = Rddb::ViewStore::S3ViewStore.new(bucket_name, :s3 => s3_config)
    assert_equal bucket_name, view_store.bucket_name
  end
  
  def test_find_and_store_and_exists
    bucket_name = 'rddb_test'
    view_store = Rddb::ViewStore::S3ViewStore.new(bucket_name, :s3 => s3_config)
    begin view_store.delete('test'); rescue; end
    assert !view_store.exists?('test')
    view_store.store('test', "create_view('test')")
    assert_equal "create_view('test')", view_store.find('test')
    assert view_store.exists?('test')
  end
  
  def test_delete
    bucket_name = 'rddb_test'
    view_store = Rddb::ViewStore::S3ViewStore.new(bucket_name, :s3 => s3_config)
    view_store.store('test', "create_view('test')")
    assert_equal "create_view('test')", view_store.find('test')
    view_store.delete('test')
    assert !view_store.exists?('test')
  end
  
  def test_each
    bucket_name = 'rddb_test'
    view_store = Rddb::ViewStore::S3ViewStore.new(bucket_name, :s3 => s3_config)
    view_store.store('test1', 'test1 code')
    view_store.store('test2', 'test2 code')
    assert_equal 2, view_store.to_a.length
    assert_equal ['test1 code', 'test2 code'], view_store.to_a.sort
  end
  
  def test_list
    bucket_name = 'rddb_test'
    view_store = Rddb::ViewStore::S3ViewStore.new(bucket_name, :s3 => s3_config)
    view_store.delete_all
    view_store.store('test1', 'test1 code')
    view_store.store('test2', 'test2 code')
    assert_equal ['test1', 'test2'], view_store.list.sort
  end
end