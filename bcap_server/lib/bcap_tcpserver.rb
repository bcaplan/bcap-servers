$: << File.dirname(__FILE__)

require 'bcap_server'
require 'socket'
require 'thread'

THREAD_NUM = 3

server = TCPServer.new(12321)
router = BcapServer::Router.new
thread_pool = Array.new

while session = server.accept
  if thread_pool.size < THREAD_NUM
    thread_pool << Thread.new(session) do |my_session|
      router.accept(my_session)
      my_session.close
    end
    thread_pool.pop
  end
  
end