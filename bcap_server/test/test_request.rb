require 'helper'

class TestRequest < Test::Unit::TestCase
  
  def setup
    test_io = StringIO.new "GET #{__FILE__} HTTP/1.0\r\n\r\n"
    @test_request = BcapServer::Request.new test_io
  end

  def test_read_stops_after_double_crlf
      test_io = StringIO.new "GET /#{File.basename(__FILE__)} HTTP/1.0\r\nHost: foo\r\nDate: today\r\n\r\nhello!"
      test_request = BcapServer::Request.new test_io
      assert_equal 'hello!', test_io.read
  end

  def test_bogus_headers_are_ignored
    test_io = StringIO.new "GET /#{File.basename(__FILE__)} HTTP/1.0\r\nHost: foo\r\nDate: today\r\n\r\n"
    test_request = BcapServer::Request.new test_io

    assert_equal "/#{File.basename(__FILE__)}", test_request.path
  end

  def test_parses_request_method_from_incoming_request
    assert_equal 'GET', @test_request.method
  end

  def test_parses_requested_path_from_incoming_request
    assert_equal "#{__FILE__}", @test_request.path
  end

end