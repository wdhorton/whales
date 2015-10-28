require 'webrick'
require_relative '../lib/my_action_controller/base'

describe MyActionDispatch::Params do
  before(:all) do
    class CatsController < MyActionController::Base
      def index
        @cats = ["Gizmo"]
      end
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  it "handles an empty request" do
    expect { MyActionDispatch::Params.new(req) }.to_not raise_error
  end

  context "query string" do
    it "handles single key and value" do
      req.query_string = "key=val"
      params = MyActionDispatch::Params.new(req)
      expect(params["key"]).to eq("val")
    end

    it "handles multiple keys and values" do
      req.query_string = "key=val&key2=val2"
      params = MyActionDispatch::Params.new(req)
      expect(params["key"]).to eq("val")
      expect(params["key2"]).to eq("val2")
    end

    it "handles nested keys" do
      req.query_string = "user[address][street]=main"
      params = MyActionDispatch::Params.new(req)
      expect(params["user"]["address"]["street"]).to eq("main")
    end

    it "handles multiple nested keys and values" do
      req.query_string =  "user[fname]=rebecca&user[lname]=smith"
      params = MyActionDispatch::Params.new(req)
      expect(params["user"]["fname"]).to eq("rebecca")
      expect(params["user"]["lname"]).to eq("smith")
    end
  end

  context "post body" do
    it "handles single key and value" do
      allow(req).to receive(:body) { "key=val" }
      params = MyActionDispatch::Params.new(req)
      expect(params["key"]).to eq("val")
    end

    it "handles multiple keys and values" do
      allow(req).to receive(:body) { "key=val&key2=val2" }
      params = MyActionDispatch::Params.new(req)
      expect(params["key"]).to eq("val")
      expect(params["key2"]).to eq("val2")
    end

    it "handles nested keys" do
      allow(req).to receive(:body) { "user[address][street]=main" }
      params = MyActionDispatch::Params.new(req)
      expect(params["user"]["address"]["street"]).to eq("main")
    end

    it "handles multiple nested keys and values" do
      allow(req).to receive(:body) { "user[fname]=rebecca&user[lname]=smith" }
      params = MyActionDispatch::Params.new(req)
      expect(params["user"]["fname"]).to eq("rebecca")
      expect(params["user"]["lname"]).to eq("smith")
    end
  end

  context "route params" do
    it "handles route params" do
      params = MyActionDispatch::Params.new(req, {"id" => 5, "user_id" => 22})
      expect(params["id"]).to eq(5)
      expect(params["user_id"]).to eq(22)
    end
  end

  context "indifferent access" do
    it "responds to string and symbol keys when stored as a string" do
      params = MyActionDispatch::Params.new(req, {"id" => 5})
      expect(params["id"]).to eq(5)
      expect(params[:id]).to eq(5)
    end
    it "responds to string and symbol keys when stored as a symbol" do
      params = MyActionDispatch::Params.new(req, {:id => 5})
      expect(params["id"]).to eq(5)
      expect(params[:id]).to eq(5)
    end
  end

  # describe "strong parameters" do
  #   describe "#permit" do
  #     it "allows the permitting of multiple attributes" do
  #       req.query_string = "key=val&key2=val2&key3=val3"
  #       params = MyActionDispatch::Params.new(req)
  #       params.permit("key", "key2")
  #       expect(params.permitted?("key")).to be_truthy
  #       expect(params.permitted?("key2")).to be_truthy
  #       expect(params.permitted?("key3")).to be_falsey
  #     end
  #
  #     it "collects up permitted keys across multiple calls" do
  #       req.query_string = "key=val&key2=val2&key3=val3"
  #       params = MyActionDispatch::Params.new(req)
  #       params.permit("key")
  #       params.permit("key2")
  #       expect(params.permitted?("key")).to be_truthy
  #       expect(params.permitted?("key2")).to be_truthy
  #       expect(params.permitted?("key3")).to be_falsey
  #     end
  #   end
  #
  #   describe "#require" do
  #     it "throws an error if the attribute does not exist" do
  #       req.query_string = "key=val"
  #       params = MyActionDispatch::Params.new(req)
  #       expect { params.require("key") }.to_not raise_error
  #       expect { params.require("key2") }.to raise_error(MyActionDispatch::Params::AttributeNotFoundError)
  #     end
  #   end
  #
  #   describe "interaction with ARLite models" do
  #     it "throws a ForbiddenAttributesError if mass assignment is attempted with unpermitted attributes" do
  #
  #     end
  #   end
  # end
end

describe 'MyActionController::Base#initialize' do
  before(:all) do
    class CatsController < MyActionController::Base
      def index
        @cats = ["Gizmo"]
      end
    end
  end

  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  context '#initialize' do
    it "sets params var to new Params object" do
      expect(cats_controller.params).to be_instance_of(MyActionDispatch::Params)
    end
  end
end
