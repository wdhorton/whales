module WhalesDispatch
  class Router

    HTML_METHODS = [:get, :post, :patch, :put, :delete]
    attr_reader :routes

    def initialize
      @routes = []
      # @last_parent_route = ""
    end

    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    def draw(&proc)
      instance_eval(&proc)
    end

    def resources(controller_noun, scope, **action_restrictions)
      @last_parent_route = "" if scope == :parent
      controller_actions = DefaultActions.new(controller_noun)
      controller_actions.parse_action_restrictions(action_restrictions)
      build_resources(controller_noun, controller_actions)

      if block_given?
        @last_parent_route = controller_noun.to_s
        yield
      end
    end

    def build_resources(controller_noun, controller_actions)
      controller_actions.actions.each do |action_name, action_hash|

        resource = Resource.new(
          controller_noun, action_hash[:suffix], @last_parent_route
        )

        send action_hash[:method], resource.pattern, resource.classify, action_name
      end
    end

    HTML_METHODS.each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name|
        add_route(pattern, http_method, controller_class, action_name)
      end
    end

    def match(req)
      routes.select { |route| route.matches?(req) }.first
    end

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
