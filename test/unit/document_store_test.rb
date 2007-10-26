require File.dirname(__FILE__) + '/../test_helper'

class DocumentStoreTest < Test::Unit::TestCase
  def test_methods_should_raise_abstract_error
    ds = Rddb::DocumentStore::Base.new
    assert_raise RuntimeError do
      ds.find('foo')
    end
    assert_raise RuntimeError do
      ds.store('foo')
    end
    assert_raise RuntimeError do
      ds.delete('foo')
    end
    assert_raise RuntimeError do
      ds.exists?('foo')
    end
    assert_raise RuntimeError do
      ds.count
    end
    assert_raise RuntimeError do
      ds.each do |document|
      end
    end
    assert_raise RuntimeError do
      ds.each_partition do
      end
    end
  end
  def test_supports_partitioning_should_default_to_false
    ds = Rddb::DocumentStore::Base.new
    assert_equal false, ds.supports_partitioning?
  end
  def test_write_indexes_should_do_nothing
    ds = Rddb::DocumentStore::Base.new
    ds.write_indexes
  end
end