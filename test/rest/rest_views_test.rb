require File.dirname(__FILE__) + '/test_helper'

class RestViewsTest < Test::Unit::TestCase
  def test_lifecycle
    url = URI.parse("http://localhost:3000")
    path = "/views/select_names"
    view_code = File.read(File.dirname(__FILE__) + '/select_names.rb')
    
    req = Net::HTTP::Delete.new(path)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    
    req = Net::HTTP::Put.new(path)
    req.body = view_code
    req['Content-Type'] = 'text/ruby'
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 201, res.code.to_i
    
    req = Net::HTTP::Get.new(path)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 200, res.code.to_i
    assert_equal view_code, res.body.to_s
    
    req = Net::HTTP::Delete.new(path)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 200, res.code.to_i
    
    req = Net::HTTP::Delete.new(path)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 404, res.code.to_i
    
    req = Net::HTTP::Get.new(path)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    assert_equal 404, res.code.to_i
  end
end