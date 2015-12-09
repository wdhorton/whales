require 'webrick'

def start_server(router)

  server = WEBrick::HTTPServer.new(Port: 3000)
  server.mount_proc('/') do |req, res|
    route = router.run(req, res)
  end

  trap('INT') { server.shutdown }

  server.start

  server
end
