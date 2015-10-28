module MyActionDispatch
  class Router

    HTML_METHODS = [:get, :post, :patch, :put, :delete]

    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    HTML_METHODS.each do |method|
      define_method(method) do |pattern, controller_class, action_name|
        add_route(pattern, method, controller_class, action_name)
      end
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      instance_eval(&proc)
    end

    # should return the route that matches this request
    def match(req)
      routes.select { |route| route.matches?(req) }.first
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      route = match(req)

      if route
        route.run(req, res)
      else
        res.status = 404
        res.body = "Could not find matching route."
      end
    end
  end
end
