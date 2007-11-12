require File.dirname(__FILE__) + '/test_helper'

class ViewStoreTest < Test::Unit::TestCase
  def test_methods_should_raise_abstract_error
    vs = Rddb::ViewStore::Base.new
    assert_raise RuntimeError do
      vs.find('name')
    end
    assert_raise RuntimeError do
      vs.store('name', 'view_code')
    end
    assert_raise RuntimeError do
      vs.delete('name')
    end
    assert_raise RuntimeError do
      vs.exists?('name')
    end
    assert_raise RuntimeError do
      vs.each { |v| v }
    end
  end
end