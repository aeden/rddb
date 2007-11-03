require File.dirname(__FILE__) + '/test_helper'

class LocalWorkerTest < Test::Unit::TestCase
  def test_process
    database = Rddb::Database.new
    database << {:name => 'Joe'}
    database << {:name => 'Jim'}
    
    p = Proc.new { |document, args| document.name }
    
    tasks = []
    tasks << Rddb::Worker::WorkerTask.new(
      :task_id, :partition, p, :view_name, database.document_store, :args
    )
    results = Rddb::Worker::LocalWorker.process(tasks)
    assert_equal 2, results.length
  end
end