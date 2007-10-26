require File.dirname(__FILE__) + '/../test_helper'

class MaterializationStoreTest < Test::Unit::TestCase
  def test_methods_should_raise_abstract_error
    ds = Rddb::MaterializationStore::Base.new
    assert_raise RuntimeError do
      ds.find('foo')
    end
    assert_raise RuntimeError do
      ds.store('foo')
    end
    assert_raise RuntimeError do
      ds.delete('foo')
    end
  end
end