module BcapServer

  class Response
    HTTP_VERSION = 'HTTP/0.9'
    STATUS_CODES = {200 => 'OK',
                    301 => 'Moved Permanently',
                    404 => 'Not Found',
                    500 => 'Internal Server Error'}
                    
    attr_accessor :status, :body, :headers
    
    def initialize
      @status = nil
      @body = nil
      @headers = Hash.new
    end
    
    def write_to io
      io.write "#{HTTP_VERSION} #{@status} #{STATUS_CODES[@status]}\r\n"

      @headers.each do |key, value|
        io.write "#{key}: #{value}\r\n"
      end

      io.write "Content-Length: #{@body.size}\r\n\r\n#{@body}" unless @body.nil?
    end
  end

end