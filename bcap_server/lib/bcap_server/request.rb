module BcapServer

  class Request
    attr_reader :method, :path

    HTTP_VERSION = 'HTTP/0.9'
    
    def initialize io
      @io = io
      parse_input
    end

    def parse_input input = @io
      parsed = input.string.split(' ')

      @method = parsed[0]
      @path = parsed[1]
    end

    def status_code
      if File.exists? @path
        '200 OK'
      else
        '404 Not Found'
      end
    end

    def header
      "#{HTTP_VERSION} #{status_code}"
    end
  end

end
