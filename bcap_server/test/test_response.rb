require 'helper'

class TestResponse < Test::Unit::TestCase
  def setup
    @test_io = StringIO.new "GET #{__FILE__} HTTP/1.0\r\n\r\n"
    @test_request = BcapServer::Request.new @test_io
    @response = BcapServer::Response.new
  end

  # def test_responds_200_when_successful
  #   assert_match /HTTP\/0\.9 200 OK/, @test_request.header
  # end
  # 
  # def test_responds_404_when_missing
  #   request = BcapServer::Request.new(StringIO.new("GET /not_there.html HTTP/1.0\r\n\r\n"))
  # 
  #   assert_match /HTTP\/0\.9 404 Not Found/, request.header
  # end

  def test_response_code_can_be_set
    response = BcapServer::Response.new
    response.status = 200

    assert_equal 200, response.status
  end

  def test_can_set_body
    @response.body = 'hello world'
    assert_equal 'hello world', @response.body
  end

  def test_response_holds_headers
    @response.headers['Content-Type'] = 'text/html'

    assert_equal 'text/html', @response.headers['Content-Type']
  end

  def test_write_to
    content = 'hello world'
    string_io = StringIO.new

    @response.status = 200
    @response.body = 'hello world'
    @response.headers['Content-Type'] = 'text/html'

    @response.write_to(string_io)

    string_io.rewind
    assert_equal "HTTP/0.9 200 OK\r\nContent-Type: text/html\r\nContent-Length: #{content.length}\r\n\r\n#{content}", string_io.read
  end

  def test_write_with_any_headers
    body = '<html><body>hello world</body></html>'
    io = StringIO.new
    @response.status = 200
    @response.body = body
    @response.headers['Content-Type'] = 'text/html'
    @response.headers['Date'] = 'today'

    @response.write_to io

    io.rewind

    written = io.read.split("\r\n")
    
    assert_equal 'HTTP/0.9 200 OK', written.first
    assert written.include?('Date: today'), 'should have date header'
    assert written.include?('Content-Type: text/html'), 'should have content type'
    assert written.include?("Content-Length: #{body.length}"), 'should have content length'
  end
end