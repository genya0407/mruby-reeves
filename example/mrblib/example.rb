module Example
  class Application < Reeves::Application
    helper do
      def render_csv(data:, csv_headers:)
        csv = ([csv_headers] + data).map { |line| line.join(',') }.join("\n")
        render raw: csv, headers: { 'Content-Type' => 'application/csv' }
      end
    end
    
    get '/topics/:topic' do
      topic = params['topic']

      render raw: "This is #{topic}"
    end

    get '/topics.json' do
      render(
        json: ['topic_1', 'topic_2'], # encode as json
        headers: { 'Content-Type' => 'application/json' }
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
  end
end

def __main__(argv)
  serv = SimpleHttpServer.new(
    host: 'localhost',
    port: '3000',
    app: Example::Application.new.to_app,
  )
  serv.run
end
