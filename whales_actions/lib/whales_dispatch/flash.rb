require 'json'
require 'webrick'

module WhalesDispatch
  class Flash

    def initialize(request)
      request.cookies.each do |cookie|
        @value_for_now = JSON.parse(cookie.value) if cookie.name == '_rails_lite_flash'
      end
      @value_for_now ||= {}
      @value_for_next = {}
    end

    def now
      @value_for_now
    end

    def [](key)
      combined = @value_for_next.merge(@value_for_now)
      combined[key.to_s] || combined[key.to_sym]
    end

    def []=(key, value)
      @value_for_next[key] = value
    end

    def store_flash(response)
      cookie = WEBrick::Cookie.new('_rails_lite_flash', @value_for_next.to_json)
      cookie.path = '/'
      response.cookies << cookie
    end

  end
end
