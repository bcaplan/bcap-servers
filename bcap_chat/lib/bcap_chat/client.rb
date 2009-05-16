require 'drb'

module BcapChat
  class Client
    include DRbUndumped
    JOIN_REGEX  = /^:join(|\s)#(\S+)/i
    LEAVE_REGEX = /^:leave/i
    DEFAULT_ROOM = 'lobby'

    attr_accessor :name

    def initialize(name, service)
      @name = name
      @service = service
      @room = DEFAULT_ROOM
      service.add_observer(self)
    end

    def start
      loop do
        message = gets.chomp
        case message
        when /^(exit|quit)$/i
          break
        when LEAVE_REGEX
          puts "Left ##{@room}" unless @room == DEFAULT_ROOM
          @room = DEFAULT_ROOM
        when JOIN_REGEX
          @room = $2
          message = { :user => @name, :action => 'Joined', :room => @room}
        end
        @service.speak(self, {:content => message, :room => @room})
      end
    end
  
    def update(who, message)
      puts "#{who.name}: #{message[:content]}" if message[:room] == @room
    end
  end
end

if $0 == __FILE__
  DRb.start_service
  server = DRbObject.new(nil, 'druby://localhost:31337')
  username = `echo $USER`.chomp.capitalize
  chatter = BcapChat::Client.new(username, server)
  chatter.start
end