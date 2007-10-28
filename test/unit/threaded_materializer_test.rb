require File.dirname(__FILE__) + '/test_helper'

class ThreadedMaterializerTest < Test::Unit::TestCase
  def test_initialization
    database = Rddb::Database.new
    materializer = Rddb::Materializer::ThreadedMaterializer.new(database)
  end
end