module BcapServer
  class Router
    SERVLETS = {}
    DIR_ROOT = Dir.pwd

    def accept io
      request = Request.new io
      response = Response.new
      path = request.path.downcase
      begin
        if SERVLETS.key? path
          SERVLETS[path].call request, response
        elsif path =~ /\/$/
          response = handle_directory(path, response)
        else
          response = handle_file(path, response)
        end
      rescue => detail
        response.status = 500
        response.headers['Content-Type'] = 'text/html'
        response.body = "<html><body><h1>500 Internal Server Error</h1><p><h2>#{detail}<br />Backtrace:</h2>#{detail.backtrace.join("<br />")}</p></body></html>"
      end
      response.write_to io
    end

    def handle_file path, response
      file = DIR_ROOT + path

      if File.exists?(file) && File.file?(file)
        response.status = 200
        response.headers['Content-Type'] = get_content_type path
        
        if File.extname(file) == '.erb'
          erb = ERB.new(File.read(file)).src
          response.body = eval(erb, binding)
        else
          response.body = File.read(file)
        end
        
      else
        do_404 path, response
      end

      response
    end

    def handle_directory path, response
      if File.exists?(DIR_ROOT + path)
        entries = ""
        Dir.foreach(DIR_ROOT + path) do |entry|
          next if entry =~ /^\./
          if File.directory? entry
            entries << "<a href=\"#{entry}/\">#{entry}/</a><br />"
          else
            entries << "<a href=\"#{entry}\">#{entry}</a><br />"
          end
        end

        response.status = 200
        response.headers['Content-Type'] = 'text/html'
        response.body = "<html><body><p>#{entries}</p></body></html>"
      else
        do_404 path, response
      end
        response
    end

    def do_404 path, response
      response.status = 404
      response.headers['Content-Type'] = 'text/html'
      response.body = "<html><body><h1>404 Could not find #{path}</h1></body></html>"
      response
    end

    def get_content_type path
      case File.extname(path)
      when '.html'
        'text/html'
      when '.erb'
        'text/html'
      else
        'text/plain'
      end
    end

    def self.register path, &block
      SERVLETS[path.downcase] = block
    end

  end
end

