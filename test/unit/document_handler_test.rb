require File.dirname(__FILE__) + '/../test_helper'

class HandlerTest < Test::Unit::TestCase
  
  def test_unsupported_method_should_return_405
    datastore = Rddb::DocumentStore::RamDocumentStore.new
    
    request = flexmock('request')
    request.should_receive(:method).and_return('FOO')
    
    response = flexmock('response')
    response.should_receive(:start).with(405, Proc).and_yield({}, flexmock(:write => "Unsupported method: FOO.\n"))
    
    handler = Rddb::Server::DocumentHandler.new(datastore)
    handler.process(request, response)
  end
  
  def test_post
    datastore = Rddb::DocumentStore::RamDocumentStore.new
  
    request = flexmock('request')
    request.should_receive(:method).and_return('POST')
    request.should_receive(:body).and_return(StringIO.new('name=John Doe&email=jdoe@foo.com'))
    
    headers = {}
    
    response = flexmock('response')
    response.should_receive(:start).with(201, Proc).and_yield(headers, 
      flexmock(:write => "The document was created.\n"))
      
    handler = Rddb::Server::DocumentHandler.new(datastore)
    handler.process(request, response)
    
    assert_equal(1, headers.length)
    assert_match(/[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/, headers['Location'])
  end
  
  def test_put_should_return_403
    datastore = Rddb::DocumentStore::RamDocumentStore.new
  
    request = flexmock('request')
    request.should_receive(:method).and_return('PUT')
    
    response = flexmock('response')
    response.should_receive(:start).with(403, Proc).and_yield({}, 
      flexmock(:write => "The document was created.\n"))
      
    handler = Rddb::Server::DocumentHandler.new(datastore)
    handler.process(request, response)
    
  end
end