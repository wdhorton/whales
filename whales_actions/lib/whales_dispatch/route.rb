require_relative './params.rb'

module WhalesDispatch
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern, @http_method =  pattern, http_method
      @controller_class, @action_name = controller_class, action_name
    end

    def matches?(req)
      params = Params.new(req)
      if req.request_method == "POST" && params["_method"]
        method = params["_method"]
      else
        method = req.request_method
      end

      pattern =~ req.path && http_method == method.downcase.to_sym
    end

    def run(req, res)
      matches = pattern.match(req.path)
      route_params = Hash[matches.names.zip(matches.captures.map(&:to_i))]
      controller = controller_class.new(req, res, route_params)
      controller.invoke_action(action_name)
    end
  end
end
