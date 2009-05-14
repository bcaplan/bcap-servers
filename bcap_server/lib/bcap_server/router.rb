module BcapServer
  class Router
    SERVLETS = {}
    DIR_ROOT = Dir.pwd

    def accept io
      request = Request.new io
      response = Response.new
      path = request.path
      begin
        if SERVLETS.key? path
          SERVLETS[path].call request, response

          output = response
        else
          output = handle_file(path, response)
        end
      rescue => detail
        response.status = 500
        response.headers['Content-Type'] = 'text/html'
        response.body = "<html><body><h1>500 Internal Server Error</h1><p><h2>Backtrace:</h2>#{detail.backtrace.join("<br />")}</p></body></html>"
        output = response
      end
      output.write_to io
    end
    
    def handle_file path, response
      file = DIR_ROOT + path
      if File.exists?(file)
        response.status = 200
        response.headers['Content-Type'] = 'text/plain'
        response.body = File.read(file)
      else
        response.status = 404
        response.headers['Content-Type'] = 'text/html'
        response.body = "<html><body><h1>404 Could not find #{path}</h1></body></html>"
      end
      response
    end

    def self.register path, &block
      SERVLETS[path] = block
    end

  end
end

BcapServer::Router.register '/time' do |request, response|
  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><h1>#{Time.now}</h1></body></html>"
end

BcapServer::Router.register '/list' do |request, response|
  entries = ""
  Dir.foreach(Dir.pwd) do |entry|
    next if entry =~ /^\./
    if File.directory? entry
      entries += "#{entry}/<br />"
    else
      entries += "#{entry}<br />"
    end
  end

  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><p>#{entries}</p></body></html>"
end

