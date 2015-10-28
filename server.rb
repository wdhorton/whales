require 'webrick'
require '/Users/appacademy/desktop/Test/routes.rb'

def start_server
  router = make_router


  server = WEBrick::HTTPServer.new(Port: 3000)
  server.mount_proc('/') do |req, res|
    route = router.run(req, res)
  end

  trap('INT') { server.shutdown }

  server.start
end
