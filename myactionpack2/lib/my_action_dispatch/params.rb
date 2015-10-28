require 'uri'

module MyActionDispatch
  class Params

    def initialize(req, route_params = {})
      parsed_query_string = parse_www_encoded_form(req.query_string)
      parsed_req_body = parse_www_encoded_form(req.body)
      @params = parsed_query_string.merge(parsed_req_body).merge(route_params)
    end

    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private

    def parse_www_encoded_form(www_encoded_form)
      www_encoded_form ||= ""
      params = {}
      URI.decode_www_form(www_encoded_form).each do |nested_key, val|
        keys = parse_key(nested_key)
        prev_context = params
        keys.each do |key|
          if key == keys.last
            prev_context[key] = val
          else
            prev_context[key] ||= {}
            prev_context = prev_context[key]
          end
        end
      end

      params
    end

    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
