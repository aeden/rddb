require File.dirname(__FILE__) + '/test_helper'

class BasicMaterializerTest < Test::Unit::TestCase
  def test_initialization
    materializer = Rddb::Materializer::BasicMaterializer.new(:database, :materialization_store)
    assert_equal :database, materializer.database
  end
end