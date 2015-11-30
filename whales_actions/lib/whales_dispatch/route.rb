module WhalesDispatch
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern, @http_method =  pattern, http_method
      @controller_class, @action_name = controller_class, action_name
    end

    def matches?(req)
      pattern =~ req.path && http_method == req.request_method.downcase.to_sym
    end

    def run(req, res)
      matches = pattern.match(req.path)
      route_params = Hash[matches.names.zip(matches.captures)]
      controller = controller_class.new(req, res, route_params)
      controller.invoke_action(action_name)
    end
  end
end
