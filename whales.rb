require 'fileutils'
require_relative 'server'
include FileUtils

def scripts(router)

  if ARGV.first == 'server' || ARGV.first == 's'
    start_server(router)
  end

  if ARGV.first == 'generate' || ARGV.first == 'g' && ARGV.length == 3
    type = ARGV[1]
    name = ARGV[2]

    cd '../Test/'

    path = "app/#{type}s/#{name.downcase}.rb"
    touch path

    if type == "model"
      File.open(path, 'w') do |f|
        f.write <<-TEXT
  require_relative '../../../whales/whales_orm/lib/base'
  class #{name.capitalize} < WhalesORM::Base
  end\n
        TEXT
      end
    elsif type == "controller"
      File.open(path, 'w') do |f|
        f.write <<-TEXT
  require_relative '../../../whales/whales_actions/lib/base'
  class #{name.capitalize} < WhalesController::Base
  end\n
        TEXT
      end
    end
  end

  if ARGV.first == "db:reset"
    DBConnection.reset
  end
end
