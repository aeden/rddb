require File.dirname(__FILE__) + '/test_helper'

class ViewHandlerTest < Test::Unit::TestCase
  def test_initialize
    view_store = Rddb::ViewStore::RamViewStore.new
    handler = Rddb::Server::ViewHandler.new(view_store)
    assert_equal view_store, handler.view_store
  end
  
  def test_invalid_http_method_should_return_405
    request = flexmock('request')
    request.should_receive(:method).and_return('FOO')
    
    response = flexmock('response')
    response.should_receive(:start).with(405, Proc).and_yield({}, flexmock(:write => "Unsupported method: FOO.\n"))
    
    handler.process(request, response)
  end
  
  def test_get_invalid_path_should_return_404
    request = flexmock('request')
    request.should_receive(:method).and_return('GET')
    request.should_receive(:path).and_return('test')
    
    out = flexmock('out')
    out.should_receive(:write).with("The view test was not found.\n")
    
    response = flexmock('response')
    response.should_receive(:start).with(404, Proc).and_yield({}, out)
    
    handler.process(request, response)
  end
  
  def test_get_valid_path_should_return_200
    handler.view_store.store('test', 'test content')

    request = flexmock('request')
    request.should_receive(:method).and_return('GET')
    request.should_receive(:path).and_return('test')
    
    out = flexmock('out')
    out.should_receive(:write).with('test content')

    response = flexmock('response')
    response.should_receive(:start).with(200, Proc).and_yield({}, out)

    handler.process(request, response)
  end
  
  def test_get_with_empty_path_should_return_403
    request = flexmock('request')
    request.should_receive(:method).and_return('GET')
    request.should_receive(:path).and_return('')
    
    out = flexmock('out')
    out.should_receive(:write).with("The root path is not allowed.\n")

    response = flexmock('response')
    response.should_receive(:start).with(403, Proc).and_yield({}, out)

    handler.process(request, response)
  end
  
  def test_post_should_return_403
    request = flexmock('request')
    request.should_receive(:method).and_return('POST')
    
    out = flexmock('out')
    out.should_receive(:write).with("The POST method is not allowed.\n")

    response = flexmock('response')
    response.should_receive(:start).with(403, Proc).and_yield({}, out)

    handler.process(request, response)
  end
  
  def test_put_for_existing_content_should_update_content_and_return_200
    handler.view_store.store('test', 'test content')
    assert_equal 'test content', handler.view_store.find('test')
    
    body = flexmock('body')
    body.should_receive(:read).and_return('modified content')
    
    request = flexmock('request')
    request.should_receive(:method).and_return('PUT')
    request.should_receive(:path).and_return('test')
    request.should_receive(:body).and_return(body)
    
    out = flexmock('out')
    out.should_receive(:write)

    response = flexmock('response')
    response.should_receive(:start).with(200, Proc).and_yield({}, out)

    handler.process(request, response)
    
    assert_equal 'modified content', handler.view_store.find('test')
  end
  
  def test_put_for_new_content_should_create_content_and_return_201
    assert_nil handler.view_store.find('test')
    
    body = flexmock('body')
    body.should_receive(:read).and_return('new content')
    
    request = flexmock('request')
    request.should_receive(:method).and_return('PUT')
    request.should_receive(:path).and_return('test')
    request.should_receive(:body).and_return(body)
    
    out = flexmock('out')
    out.should_receive(:write)

    response = flexmock('response')
    response.should_receive(:start).with(201, Proc).and_yield({}, out)

    handler.process(request, response)
    
    assert_equal 'new content', handler.view_store.find('test')
  end
  
  def test_put_with_empty_path_should_return_403
    request = flexmock('request')
    request.should_receive(:method).and_return('PUT')
    request.should_receive(:path).and_return('')
    
    out = flexmock('out')
    out.should_receive(:write).with("The root path is not allowed.\n")

    response = flexmock('response')
    response.should_receive(:start).with(403, Proc).and_yield({}, out)

    handler.process(request, response)
  end
  
  def test_delete_for_existing_content_should_delete_content_and_return_200
    handler.view_store.store('test', 'test content')
    assert_equal 'test content', handler.view_store.find('test')

    request = flexmock('request')
    request.should_receive(:method).and_return('DELETE')
    request.should_receive(:path).and_return('test')

    out = flexmock('out')
    out.should_receive(:write).with("The view test was deleted.\n")

    response = flexmock('response')
    response.should_receive(:start).with(200, Proc).and_yield({}, out)

    handler.process(request, response)

    assert_nil handler.view_store.find('test')
  end
  
  def test_delete_for_non_existent_content_should_return_404
    request = flexmock('request')
    request.should_receive(:method).and_return('DELETE')
    request.should_receive(:path).and_return('test')

    out = flexmock('out')
    out.should_receive(:write).with("The view test does not exist.\n")

    response = flexmock('response')
    response.should_receive(:start).with(404, Proc).and_yield({}, out)

    handler.process(request, response)
  end
  
  protected
  def handler
    @handler ||= Rddb::Server::ViewHandler.new(Rddb::ViewStore::RamViewStore.new)
  end
end