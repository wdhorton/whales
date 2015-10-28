require 'webrick'
require_relative '../lib/my_action_controller/base'

describe MyActionController::Base do
  before(:all) do
    class CatsController < MyActionController::Base
      def index
        @cats = ["GIZMO"]
      end
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  describe "#render" do
    before(:each) do
      cats_controller.render(:index)
    end

    it "renders the html of the index view" do
      expect(cats_controller.res.body).to include("ALL THE CATS")
      expect(cats_controller.res.body).to include("<h1>")
      expect(cats_controller.res.content_type).to eq("text/html")
    end

    describe "#already_built_response?" do
      let(:cats_controller2) { CatsController.new(req, res) }

      it "is false before rendering" do
        expect(cats_controller2.already_built_response?).to be_falsey
      end

      it "is true after rendering content" do
        cats_controller2.render(:index)
        expect(cats_controller2.already_built_response?).to be_truthy
      end

      it "raises an error when attempting to render twice" do
        cats_controller2.render(:index)
        expect do
          cats_controller2.render(:index)
        end.to raise_error
      end
    end
  end
end
