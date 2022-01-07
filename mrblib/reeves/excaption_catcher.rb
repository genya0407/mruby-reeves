module Reeves
  class ExceptionCatcher
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue => e
        $stderr.puts e.message
        e.backtrace.each { |l| $stderr.puts l }

        [500, {}, ['Internal server error']]
      end
    end
  end
end

