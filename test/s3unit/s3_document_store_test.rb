require File.dirname(__FILE__) + '/test_helper'

class S3DocumentStoreTest < Test::Unit::TestCase
  include AWS::S3
  include S3Config
  
  def test_store_and_find
    bucket_name = 'rddb-test'
    
    ps = Proc.new { |document| document.name[0..0] }
    
    d1 = create_document
    ds = Rddb::DocumentStore::S3DocumentStore.new(bucket_name,
      :s3 => s3_config,
      :partition_strategy => ps,
      :basedir => 'store_and_find'
    )
    
    Bucket.find(bucket_name).delete_all
    
    ds.store(d1)
    assert ds.exists?(d1.id)
    assert_equal d1, ds.find(d1.id)
    
    d2 = create_document(:name => 'test2')
    ds.store(d2)
    assert ds.exists?(d2.id)
    assert_equal d2, ds.find(d2.id)
    
    d3 = create_document(:name => 'foobar')
    d4 = create_document(:name => 'foobar2')
    ds.store(d3)
    ds.store(d4)
    assert ds.exists?(d3.id)
    assert ds.exists?(d4.id)
    assert_equal d3, ds.find(d3.id)
    assert_equal d4, ds.find(d4.id)
    assert_equal 4, ds.count
    
    assert_equal d1, ds.find(d1.id)
  end
  
  protected
  def create_document(options={})
    Rddb::Document.new({:name => 'test'}.merge(options))
  end
end