module Reeves
  class Action
    # for debug
    module KernelExt
      def to_enum(*o)
        super
      end
    end

    Kernel.prepend KernelExt
    
    class Request
      attr_reader :env

      def initialize(env:)
        @env = env
      end

      def body
        env['genya0407.request_body']
      end

      def json
        JSON.parse(body)
      end

      def headers
        env
      end
    end

    class Response
      attr_reader :body, :headers, :status

      def initialize(body:, headers:, status:)
        @status = status
        @headers = headers
        @body = body
      end

      def to_a
        [status, headers, body]
      end
    end
    
    def initialize(env:, block:)
      @env = env
      @block = block
    end

    def request
      @request ||= Request.new(env: @env)
    end

    def params
      @params ||= @env['shelf.request.query_hash'].transform_keys(&:to_s)
    end

    def render(erb: nil, json: nil, raw: nil, headers: {}, status: 200)
      raise 'You must specify exactly one of erb or json or raw' unless [erb, json, raw].reject(&:nil?).size == 1

      body = if erb
        template = ERB.new(File.read(erb))
        [template.result(self)]
      elsif json
        [JSON.dump(json)]
      else
        [raw]
      end

      Response.new(
        status: status,
        body: body,
        headers: headers
      )
    end
  end
end
