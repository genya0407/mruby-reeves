module Reeves
  class Application
    class << self
      def mapping
        @mapping ||= {}
      end
      
      %i[get post delete put].each do |method|
        define_method method do |path, &block|
          mapping[[method, path]] = block
        end
      end

      def helper(&block)
        @helper_block = block
      end

      def helper_block
        @helper_block || proc {} # ヘルパーが指定されなかったときのデフォルト値
      end
    end

    def to_app
      # Shelf::Builder.app 内での self は Reeves::Application ではないので、以下は実行できない。
      # そのため、ここで実行してローカル変数に束縛する必要がある
      mapping = self.class.mapping
      action_class = Class.new(Action, &self.class.helper_block)

      Shelf::Builder.app do
        use Shelf::QueryParser
        mapping.each do |(method, path), block|
          if path =~ %r{:} && !(path =~ %r{:[^/]+$})
            raise "Invalid path pattern: #{path.inspect}. Dynamic path must exist at the end of pattern."
          end
          
          path_param_names = []
          path_for_shelf = path.gsub(%r{:[^/]+}) do |m|
            name = m.gsub(':', '')
            path_param_names << name
            "{#{name}:[^/]+}"
          end

          send(method, path_for_shelf) do
            run ->(env) do
              response = action_class.new(env: env, block: block).instance_eval(&block)
              raise 'Invalid action. You must execute `render` at the end of the action.' unless response.is_a?(Action::Response)

              response.to_a
            end
          end
        end
      end
    end
  end
end