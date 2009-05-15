BcapServer::Router.register '/time' do |request, response|
  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><h1>#{Time.now}</h1></body></html>"
end

BcapServer::Router.register '/' do |request, response|
  entries = ""
  Dir.foreach(Dir.pwd) do |entry|
    next if entry =~ /^\./
    if File.directory? entry
      entries += "#{entry}/<br />"
    else
      entries += "#{entry}<br />"
    end
  end

  response.status = 200
  response.headers['Content-Type'] = 'text/html'
  response.body = "<html><body><p>#{entries}</p></body></html>"
end