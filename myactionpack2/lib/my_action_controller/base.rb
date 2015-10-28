require 'active_support/inflector'
require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative '../my_action_dispatch/flash'
require_relative '../my_action_dispatch/params'
require_relative '../my_action_dispatch/route'
require_relative '../my_action_dispatch/router'
require_relative '../my_action_dispatch/session'
require 'byebug'

module MyActionController
  class Base
    attr_reader :params
    attr_accessor :res, :req

    def initialize(request, response, route_params = {})
      @req = request
      @res = response
      @params = MyActionDispatch::Params.new(req, route_params)

      unless req.request_method == "GET"
        verify_authenticity_token
      end
    end

    def already_built_response?
      @already_built_response
    end

    def flash
      @flash ||= MyActionDispatch::Flash.new(req)
    end

    def form_authenticity_token
      session["authenticity_token"] = SecureRandom.urlsafe_base64
    end

    def invoke_action(action_name)
      send(action_name)
      render(name) unless already_built_response?
    end

    def render_content(content, content_type)
      raise if already_built_response?
      self.res.content_type = content_type
      self.res.body = content
      @already_built_response = true
      session.store_session(res)
      flash.store_flash(res)
    end

    def redirect_to(url)
      raise if already_built_response?
      self.res["Location"] = url
      self.res.status = 302
      @already_built_response = true
      session.store_session(res)
      flash.store_flash(res)
    end

    def render(template_name)
      path = File.expand_path("../../views/#{self.class.to_s.underscore}/#{template_name}.html.erb", __FILE__)
      template = ERB.new(File.read(path))
      render_content(template.result(binding), "text/html")
    end

    def session
      @session ||= MyActionDispatch::Session.new(req)
    end

    private

    def verify_authenticity_token
      unless params[:authenticity_token] == session["authenticity_token"]
        raise "Missing authenticity token"
      end
    end

  end
end
