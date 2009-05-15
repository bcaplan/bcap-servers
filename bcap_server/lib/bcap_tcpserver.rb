$: << File.dirname(__FILE__)

require 'bcap_server'
require 'socket'

server = TCPServer.new(12321)
router = BcapServer::Router.new
while session = server.accept
  Thread.new(session) do |my_session|
    router.accept(my_session)
    my_session.close
  end
end