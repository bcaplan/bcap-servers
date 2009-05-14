module BcapServer
  class Request
    attr_reader :method, :path

    def initialize io
      @io = io
      @method = nil
      @path = nil
      parse_input
    end

    def parse_input io = @io
      io.each_line do |line|

        break if line == "\r\n"

        unless @method && @path
          parsed = line.split(' ')

          @method = parsed[0]
          @path   = parsed[1]
        end

      end
    end

  end
end
