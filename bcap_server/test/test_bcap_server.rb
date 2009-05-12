require "test/unit"
require "bcap_server"

class TestBcapServer < Test::Unit::TestCase
  include BcapServer

  def setup
    @test_request = Request.new
    puts @test_request.class
    @test_io = StringIO.new "hello world!"
  end

  def test_responds_200_when_successful
    request = Request.new(StringIO.new("GET something HTTP/1.0"))

    assert_match /HTTP\/0\.9 200 OK/, @test_request.header
  end

  def test_responds_404_when_missing
    request = Request.new(StringIO.new("GET /something_not_here HTTP/1.0"))

    assert_match /HTTP\/0\.9 404 Not Found/, request.header
  end

  def test_case_name
    
  end
end
