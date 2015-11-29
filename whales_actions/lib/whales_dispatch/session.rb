require 'json'
require 'webrick'

module WhalesDispatch
  class Session

    def initialize(request)
      request.cookies.each do |cookie|
        @value = JSON.parse(cookie.value) if cookie.name == '_rails_lite_app'
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
      cookie = WEBrick::Cookie.new('_rails_lite_app', @value.to_json)
      cookie.path = '/'
      response.cookies << cookie
    end

  end
end
