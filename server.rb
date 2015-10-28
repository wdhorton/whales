require 'webrick'

def start_server
  server = WEBrick::HTTPServer.new(Port: 3000)
  server.mount_proc('/') do |req, res|
    response.content_type = "text/text"
    response.body = "Your server is running!"
  end

  trap('INT') { server.shutdown }

  server.start
end
