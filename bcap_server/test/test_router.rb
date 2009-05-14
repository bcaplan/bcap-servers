require 'helper'

class TestRouter < Test::Unit::TestCase
  def setup
    @router = BcapServer::Router.new
  end

  def test_404
    io = StringIO.new("GET /asdfadsfadf HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.read.split("\r\n")
    assert response.include?('404 Not Found'), 'should have 404 status'
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?(body)    
  end

  def test_routes_a_proc
    called = false
    BcapServer::Router.register '/time' do |request, response|
      called = true
    end

    io = StringIO.new("GET /time HTTP/1.0\r\n\r\n")
    @router.accept(io)

    assert called, "our proc should have been called"
  end

  def test_routes_a_proc_and_renders_body
    called = false
    body = "<html><body><h1>#{Time.now}</h1></body></html>"
    BcapServer::Router.register '/time' do |request, response|
      called = true
      response.status = 200
      response.headers['Content-Type'] = 'text/html'
      response.body = body
    end

    io = StringIO.new("GET /time HTTP/1.0\r\n\r\n")
    @router.accept(io)

    assert called, "our proc should have been called"


    response = io.read.split("\r\n")
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?(body)
  end
end