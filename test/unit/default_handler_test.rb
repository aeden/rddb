require File.dirname(__FILE__) + '/test_helper'

class DefaultHandlerTest < Test::Unit::TestCase
  def test_all_methods
      assert_nothing_raised do
      %w|GET POST PUT DELETE|.each do |method|
        request = flexmock('request')
        request.should_receive(:method).and_return('FOO')
    
        response = flexmock('response')
        response.should_receive(:start).with(200, Proc).and_yield(
          {}, flexmock(:write => "Nothing.\n")
        )
    
        handler = Rddb::Server::DefaultHandler.new
        handler.process(request, response)
      end
    end
  end
end