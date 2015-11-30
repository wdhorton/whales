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

    path = "app/#{type}s/#{name.downcase}.rb"
    touch path

    if type == "model"
      File.open(path, 'w') do |f|
        f.write <<-TEXT
require_relative '../../../whales/whales_orm/lib/base'
require_relative '../../config/database.rb'

class #{name.capitalize} < WhalesORM::Base
  self.finalize!
end\n
        TEXT
      end
    elsif type == "controller"
      File.open(path, 'w') do |f|
        f.write <<-TEXT
require_relative 'application_controller'

class #{name.capitalize} < ApplicationController
end\n
        TEXT
      end

      mkdir "app/views/#{name.downcase}"
    end
  end

  if ARGV.first == "db:reset"
    DBConnection.reset
  end
end
