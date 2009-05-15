BcapServer::Router.register '/time' do |request, response|
  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><h1>#{Time.now}</h1></body></html>"
end

BcapServer::Router.register '/date' do |request, response|
  response.status = 301
  response.headers['Location'] = '/time'
end