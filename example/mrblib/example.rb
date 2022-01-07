module Example
  class MyMimeMiddleware
    def initialize(app, mime_source = {})
      @app = app
      @mime_source = mime_source
      @mime_regex = /\.([^.]+)$/
    end

    def call(env)
      status, headers, body = @app.call(env)

      if mime = calculate_mime(env[Shelf::PATH_INFO])
        headers = { 'Content-Type' => mime }.merge(headers)
      end

      [status, headers, body]
    end

    private
    def calculate_mime(path)
      ext = @mime_regex.match(path)&.[](1)
      @mime_source[ext]
    end
  end

  class Application < Reeves::Application
    helper do
      def render_csv(data:, csv_headers:)
        csv = ([csv_headers] + data).map { |line| line.join(',') }.join("\n")
        render raw: csv, headers: { 'Content-Type' => 'text/csv' }
      end
    end

    MIME_SOURCE = {
      'json' => 'application/json',
      'csv' => 'text/csv',
      'html' => 'text/html',
      'css' => 'text/css',
    }
    use MyMimeMiddleware, MIME_SOURCE

    public_dir root: 'public', urls: ['/javascript']
    
    get '/topics/:topic' do
      topic = params['topic']

      render raw: "This is #{topic}"
    end

    get '/topics.json' do
      render(
        json: ['topic_1', 'topic_2'], # encode as json
      )
    end

    get '/topics.csv' do
      render_csv(
        data: [['topic_1', 'value_1'], ['topic_2', 'value_2']],
        csv_headers: ['topic', 'value']
      )
    end

    post '/topics/upload' do
      puts request.body # raw body
      puts request.json # decode body as json

      render raw: request.json['data'], status: 422
    end

    get '/do_redirect' do
      redirect_to '/redirected'
    end

    get '/redirected' do
      render raw: 'Redirected'
    end

    get '/' do
      @topics = %w[aaa bbb ccc]

      render erb: 'views/index.html.erb'
    end

    get '/application.css' do
      send_file 'assets/application.css'
    end
  end
end

def __main__(argv)
  serv = SimpleHttpServer.new(
    host: 'localhost',
    port: '3000',
    run_gc_per_request: true,
    app: Example::Application.new.to_app,
  )
  serv.run
end
