require 'bcap_server/request'
require 'bcap_server/response'
require 'bcap_server/router'
require 'gserver'

module BcapServer
  VERSION = '1.0.0'
end

# class BcapGServer < GServer
# 
#   def initialize(port=12321, *args)
#     super
#   end
#   def serve(io)
#     @router = BcapServer::Router.new
#     @router.accept(io)
#   end
# end
# # Run the server with logging enabled (it's a separate thread).
# server = BcapGServer.new
# server.audit = true                  # Turn logging on.
# server.start
# server.join
