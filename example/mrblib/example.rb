module Example
  class Application < Reeves::Application
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
