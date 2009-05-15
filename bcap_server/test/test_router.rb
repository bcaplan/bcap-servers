require 'helper'

class TestRouter < Test::Unit::TestCase
  def setup
    @router = BcapServer::Router.new
    open('test/test.html.erb', 'w') { |f| f.write "<html><body><h1><%= 1.class %></h1></body></html>"}
  end

  def teardown
    FileUtils.rm('test/test.html.erb') if File.exist?('test/test.html.erb')
  end

  def test_404
    io = StringIO.new("GET /asdfadsfadf HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 404 Not Found'), 'should have 404 status'
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?('<html><body><h1>404 Could not find /asdfadsfadf</h1></body></html>')    
  end

  def test_responds_with_file_if_it_exists
    io = StringIO.new("GET /test/#{File.basename(__FILE__)} HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 200 OK'), 'should have 200 status'
    assert response.include?('Content-Type: text/plain'), "should have content type header"
    assert response.include?(File.read(__FILE__)), "should have body of this test file"
  end
  
  def test_responds_with_dir_list_if_dir
    io = StringIO.new("GET /test/ HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert_match File.basename(__FILE__), response.last
    assert response.include?('HTTP/0.9 200 OK'), 'should have 200 status'
    assert response.include?('Content-Type: text/html'), "should have content type header"
  end

  def test_routes_a_proc
    called = false
    BcapServer::Router.register '/time' do |request, response|
      called = true
      response.body = 'body'
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

    response = io.string.split("\r\n")
    assert response.include?('Content-Type: text/html'), "should have content type header"

    assert response.include?(body), "should have body"
  end
  
  def test_redirects_with_301
    BcapServer::Router.register '/date' do |request, response|
      response.status = 301
      response.headers['Location'] = '/time'
    end

    io = StringIO.new("GET /date HTTP/1.0\r\n\r\n")
    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('HTTP/0.9 301 Moved Permanently'), "should have 301 status"
    assert response.include?('Location: /time'), "should have location"
  end
  
  def test_renders_erb
    io = StringIO.new("GET /test/test.html.erb HTTP/1.0\r\n\r\n")
    body = "<html><body><h1>Fixnum</h1></body></html>"

    @router.accept(io)

    response = io.string.split("\r\n")
    assert response.include?('Content-Type: text/html'), "should have html content type header"
    assert response.include?(body), "should have parsed body"
  end
  
  def test_renders_500_on_rescue
    BcapServer::Router.register '/raise' do |request, response|
      raise
    end
    
    io = StringIO.new("GET /raise HTTP/1.0\r\n\r\n")
    
    @router.accept(io)
    
    response = io.string.split("\r\n")
    assert response.include?('Content-Type: text/html'), "should have content type header"
    assert response.include?('HTTP/0.9 500 Internal Server Error'), 'should have 500 status'
  end
  
  def test_gets_content_type_html
    actual = @router.get_content_type '/index.html'

    assert_equal 'text/html', actual
  end
  
  def test_gets_content_type_erb
    actual = @router.get_content_type '/index.html.erb'

    assert_equal 'text/html', actual
  end
  
  def test_gets_content_type_other
    actual = @router.get_content_type '/index.rb'

    assert_equal 'text/plain', actual
  end
end