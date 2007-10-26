require File.dirname(__FILE__) + '/../test_helper'

class PartitionedFileDocumentStoreTest < Test::Unit::TestCase
  def test_store_and_find
    ps = Proc.new { |document| document.name[0..0] }
    
    d1 = create_document
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :partition_strategy => ps,
      :basedir => File.dirname(__FILE__) + '/../tmp/store_and_find'
    )
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
  
  def test_store_and_find_with_default_partition_strategy
    d1 = create_document
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/store_and_find_with_default_partition_strategy'
    )
    ds.store(d1)
    assert ds.exists?(d1.id)
    assert_equal d1, ds.find(d1.id)
    assert_equal 1, ds.count
    
    d2 = create_document(:name => 'test2')
    ds.store(d2)
    assert ds.exists?(d2.id)
    assert_equal d2, ds.find(d2.id)
    assert_equal 2, ds.count
    
    d3 = create_document(:name => 'foobar')
    d4 = create_document(:name => 'foobarbaz')
    ds.store(d3)
    ds.store(d4)
    assert ds.exists?(d3.id)
    assert ds.exists?(d4.id)
    assert_equal d3, ds.find(d3.id)
    assert_equal d4, ds.find(d4.id)
    assert_equal 4, ds.count
    
    assert_equal d1, ds.find(d1.id)
  end
  
  def test_each_partition
    ps = Proc.new { |document| document.name[0..0] }
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/test_each_partition',
      :partition_strategy => ps
    )
    ds.store(create_document(:name => 'a1'))
    ds.store(create_document(:name => 'b1'))
    ds.store(create_document(:name => 'c1'))

    partitions = []
    ds.each_partition do |p|
      partitions << p
    end
    assert_equal 3, partitions.length
    assert_equal ['a','b','c'], partitions
  end
  
  def test_each_with_partition
    f = File.dirname(__FILE__) + '/../tmp/test_each_with_partition'
    FileUtils.rm_rf(f) if File.exist?(f)
    
    ps = Proc.new { |document| document.name[0..0] }
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/test_each_with_partition',
      :partition_strategy => ps
    )
    ds.store(create_document(:name => 'a1'))
    ds.store(create_document(:name => 'a2'))
    ds.store(create_document(:name => 'b2'))
    
    documents = []
    ds.each('a') do |document|
      documents << document
    end
    assert_equal 2, documents.length
  end
  
  def test_delete_should_raise_error
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/delete_should_raise_error'
    )
    assert_raise RuntimeError do
      ds.delete('foo')
    end
  end
  
  def test_write_indexes_and_then_load_indexes
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/test_write_indexes'
    )
    ds.store(create_document(:name => 'a1'))
    ds.store(create_document(:name => 'a2'))
    ds.store(create_document(:name => 'b2'))
    
    assert_nothing_raised do
      ds.write_indexes
    end
    
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/test_write_indexes'
    )
  end
  
  def test_with_cache
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/test_with_cache',
      :cache => Hash
    )
    d = create_document(:name => 'a1')
    ds.store(d)
    d_found = ds.find(d.id)
    assert_not_nil d_found
    assert_equal d_found, d
  end
  
  def test_each_ignoring_partitioning
    f = File.dirname(__FILE__) + '/../tmp/test_each_with_partition'
    FileUtils.rm_rf(f) if File.exist?(f)
    
    ps = Proc.new { |document| document.name[0..0] }
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/test_each_with_partition',
      :partition_strategy => ps
    )
    ds.store(create_document(:name => 'a1'))
    ds.store(create_document(:name => 'a2'))
    ds.store(create_document(:name => 'b2'))
    
    documents = []
    ds.each do |document|
      documents << document
    end
    assert_equal 3, documents.length
  end
  
  def test_supports_partitioning_should_return_true
    ds = Rddb::DocumentStore::PartitionedFileDocumentStore.new(
      :basedir => File.dirname(__FILE__) + '/../tmp/empty'
    )
    assert ds.supports_partitioning?
  end
  
  protected
  def create_document(options={})
    Rddb::Document.new({:name => 'test'}.merge(options))
  end
end