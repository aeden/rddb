require File.dirname(__FILE__) + '/test_helper'

class Ec2WorkerTest < Test::Unit::TestCase
  def test_initialization
    worker = Rddb::Worker::Ec2Worker.new(options)
    assert_equal 'rddb_queue', worker.queue_name
    assert_equal 'ACCESS_KEY_ID', SQS.access_key_id
    assert_equal 'SECRET_ACCESS_KEY', SQS.secret_access_key
  end
  
  def test_create_message
    document_store = Rddb::DocumentStore::RamDocumentStore.new
    args = {:x => 10, :y => 'foo'}
    task = Rddb::Worker::WorkerTask.new(
      'task_id', 'partition', :process, 'a view', document_store, args
    )
    xml = Rddb::Worker::Ec2Worker.create_message(task)
    assert_equal '<message><task_id>task_id</task_id><partition>partition</partition><view_name>a view</view_name><document_store>Rddb::DocumentStore::RamDocumentStore</document_store><arg><name>x</name><value>10</value></arg><arg><name>y</name><value>foo</value></arg></message>', xml
  end
  
  protected
  def options
    {
      :sqs => {
        :credentials => {
          :access_key_id => 'ACCESS_KEY_ID',
          :secret_access_key => 'SECRET_ACCESS_KEY',
          :queue_name => 'rddb_queue'
        }
      }
    }
  end
end