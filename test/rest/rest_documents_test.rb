require File.dirname(__FILE__) + '/test_helper'

class RestDocumentsTest < Test::Unit::TestCase
  def test_lifecycle
    url = URI.parse("http://localhost:3000")
    path = "/documents/"
    
    req = Net::HTTP::Post.new(path)
    pairs = []
    {:name => 'Bob', :email => 'bob@foo.com'}.each do |key, value|
      pairs << "#{CGI.escape(key.to_s)}=#{CGI.escape(value)}"
    end
    req.body = pairs.join('&')
    
    req['Content-Type'] = 'application/x-www-form-encoded'
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 201, res.code.to_i
    puts res.header['Location']
    
    path = res.header['Location']
    
    req = Net::HTTP::Get.new(path)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 200, res.code.to_i
    assert res.body.split('&').include?('name=Bob')
    
    #     req = Net::HTTP::Delete.new(path)
    #     res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    #     assert_equal 200, res.code.to_i
    #     
    #     req = Net::HTTP::Delete.new(path)
    #     res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    #     assert_equal 404, res.code.to_i
    #     
    #     req = Net::HTTP::Get.new(path)
    #     res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    #     assert_equal 404, res.code.to_i
  end
end