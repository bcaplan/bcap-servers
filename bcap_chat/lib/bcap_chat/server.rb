require 'drb'
require 'drb/observer'

module BcapChat
  class Server
    include DRb::DRbObservable
    
    def speak(who, message)
      changed(true)
      if message[:content].is_a? Hash
        notify_observers(who, { :content => "#{message[:content][:action]} ##{message[:room]}", :room => message[:room]})
      else
        notify_observers(who, message)
      end
    end
    
  end
end

if $0 == __FILE__
  DRb.start_service('druby://localhost:31337', BcapChat::Server.new)
  DRb.thread.join
end