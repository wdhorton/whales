require 'webrick'
require_relative '../lib/my_action_controller/base'

describe "the symphony of things" do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }

  before(:all) do
    class Ctrlr < MyActionController::Base
      def route_render
        render_content("testing", "text/html")
      end

      def route_does_params
        render_content("got ##{ params["id"] }", "text/text")
      end

      def update_session
        session[:token] = "testing"
        render_content("hi", "text/html")
      end
    end
  end
  after(:all) { Object.send(:remove_const, "Ctrlr") }

  describe "routes and params" do
    it "route instantiates controller and calls invoke action" do
      route = MyActionDispatch::Route.new(Regexp.new("^/statuses/(?<id>\\d+)$"), :get, Ctrlr, :route_render)
      allow(req).to receive(:path) { "/statuses/1" }
      allow(req).to receive(:request_method) { :get }
      route.run(req, res)
      expect(res.body).to eq("testing")
    end

    it "route adds to params" do
      route = MyActionDispatch::Route.new(Regexp.new("^/statuses/(?<id>\\d+)$"), :get, Ctrlr, :route_does_params)
      allow(req).to receive(:path) { "/statuses/1" }
      allow(req).to receive(:request_method) { :get }
      route.run(req, res)
      expect(res.body).to eq("got #1")
    end
  end

  describe "controller sessions" do
    let(:ctrlr) { Ctrlr.new(req, res) }

    it "exposes a session via the session method" do
      expect(ctrlr.session).to be_instance_of(MyActionDispatch::Session)
    end

    it "saves the session after rendering content" do
      ctrlr.update_session
      expect(res.cookies.count).to be >= 1
      expect(JSON.parse(res.cookies[0].value)["token"]).to eq("testing")
    end
  end
end
