module Reeves
  class Application
    class << self
      def mapping
        @mapping ||= {}
      end

      def public_dir_setting
        @public_dir_setting ||= []
      end
      
      %i[get post delete put].each do |method|
        define_method method do |path, &block|
          mapping[[method, path]] = block
        end
      end

      def public_dir(root:, urls:)
        public_dir_setting << { root: root, urls: urls }
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
      public_dir_setting = self.class.public_dir_setting
      action_class = Class.new(Action, &self.class.helper_block)

      Shelf::Builder.app do
        use Shelf::QueryParser

        public_dir_setting.each do |setting|
          use Shelf::Static, root: setting[:root], urls: setting[:urls]
        end

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
              begin
                response = action_class.new(env: env, block: block).instance_eval(&block)
              rescue => e
                $stderr.puts "#{e.message}"
                e.backtrace.each { |l| $stderr.puts l }
                break render(raw: 'Internal server error', status: 500)
              end

              raise 'Invalid action. You must execute `render` or `redirect_to` at the end of the action.' unless response.is_a?(Action::Response)

              response.to_a
            end
          end
        end
      end
    end
  end
end
