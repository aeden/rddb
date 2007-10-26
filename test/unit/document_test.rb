require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < Test::Unit::TestCase
  def test_generated_id
    document = Rddb::Document.new
    assert_match(/[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/, document.id)
  end
  
  def test_specified_id
    document = Rddb::Document.new(:id => 1)
    assert_equal 1, document.id
  end
  
  def test_get_named_attribute
    document = Rddb::Document.new(:name => 'Bob')
    assert_equal 'Bob', document[:name]
  end
  
  def test_set_named_attribute
    document = Rddb::Document.new
    assert_nil document[:name]
    document[:name] = 'Jim'
    assert_equal 'Jim', document[:name]
  end
  
  def test_attribute?
    document = Rddb::Document.new(:name => 'Bob')
    assert document.attribute?(:name)
    assert !document.attribute?(:foo)
  end
  
  def test_to_s
    document = Rddb::Document.new(:id => 1, :name => 'Bob')
    assert_equal '{:name=>"Bob", :id=>1}', document.to_s
  end
  
  def test_inspect
    document = Rddb::Document.new(:id => 1, :name => 'Bob')
    assert_equal '{:name=>"Bob", :id=>1}', document.to_s
  end
end