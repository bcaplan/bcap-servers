require 'helper'

class TestBcapServer < Test::Unit::TestCase

  def setup
    @test_io = StringIO.new "GET #{__FILE__} HTTP/1.0\r\n\r\n"
    @test_request = BcapServer::Request.new @test_io
  end

  def test_parses_request_method_from_incoming_request
    actual = @test_request.method
    
    assert_equal 'GET', actual
  end

  def test_parses_requested_path_from_incoming_request
    actual = @test_request.path
    
    assert_equal "#{__FILE__}", actual
  end
end
