require 'yaml'
require 'webrick'

module WhalesDispatch
  class Session

    def initialize(request)
      request.cookies.each do |cookie|
        @value = YAML.load(cookie.value) if cookie.name == '_whales_app'
      end
      @value ||= {}
    end

    def [](key)
      @value[key.to_s] || @value[key.to_sym]
    end

    def []=(key, value)
      @value[key.to_s] = value
    end

    def store_session(response)
      cookie = WEBrick::Cookie.new('_whales_app', @value.to_yaml)
      puts "got past cookie"
      cookie.path = '/'
      response.cookies << cookie
      puts "added cookie to response"
    end

  end
end
