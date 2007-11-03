require File.dirname(__FILE__) + '/test_helper'

class ViewStoreTest < Test::Unit::TestCase
  def test_methods_should_raise_abstract_error
    ds = Rddb::ViewStore::Base.new
    assert_raise RuntimeError do
      ds.find('name')
    end
    assert_raise RuntimeError do
      ds.store('name', 'view_code')
    end
    assert_raise RuntimeError do
      ds.delete('name')
    end
    assert_raise RuntimeError do
      ds.exists?('name')
    end
  end
end