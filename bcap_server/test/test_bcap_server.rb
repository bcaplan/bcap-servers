require 'helper'

class TestBcapServer < Test::Unit::TestCase
  include BcapServer

  def setup
    @test_io = StringIO.new "GET #{__FILE__} HTTP/1.0\r\n\r\n"
    @test_request = Request.new @test_io
  end

  def test_parses_request_method_from_incoming_request
    actual = @test_request.method
    
    assert_equal 'GET', actual
  end

  def test_parses_requested_path_from_incoming_request
    actual = @test_request.path
    
    assert_equal "#{__FILE__}", actual
  end

  def test_responds_200_when_successful
    assert_match /HTTP\/0\.9 200 OK/, @test_request.header
  end

  def test_responds_404_when_missing
    request = Request.new(StringIO.new("GET /not_there.html HTTP/1.0\r\n\r\n"))

    assert_match /HTTP\/0\.9 404 Not Found/, request.header
  end
end
