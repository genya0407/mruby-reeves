# Reeves ![test](https://github.com/genya0407/mruby-reeves/actions/workflows/test.yml/badge.svg)

Simple web framework for mruby.

```ruby
module Example
  class Application < Reeves::Application
    # You can define helper method
    helper do
      def render_csv(data:, csv_headers:)
        csv = ([csv_headers] + data).map { |line| line.join(',') }.join("\n")
        render raw: csv, headers: { 'Content-Type' => 'application/csv' }
      end
    end

    # get / post / put / delete are supported
    get '/topics' do
      render(
        status: 200,
        raw: 'returns plain text as HTML body',
        headers: { 'Content-Type' => 'text/plain' }
      )
    end

    # "path parameter" is supported
    get '/topics/:topic' do
      topic = params['topic']

      render raw: "This is #{topic}"
    end

    get '/topics.csv' do
      # You can use helpers you defined above
      render_csv(
        data: [['topic_1', 'value_1'], ['topic_2', 'value_2']],
        csv_headers: ['topic', 'value']
      )
    end

    post '/topics/upload' do
      puts request.body # raw body as string
      puts request.json # decode body as json object

      render raw: request.json['data']
    end
    
    get '/topics.html' do
      @topics = ['topic_1', 'topic_2']
      
      # You can use template engine (currently, only erb is supported)
      render erb: 'views/index.html.erb'
    end

    post '/topics' do
      id = create_topic(name: request.json['topic'])

      # redirection is supported
      redirect_to "/topics/#{id}"
    end
  end
end

def __main__(argv)
  # You can generate Shelf app
  # See: https://github.com/katzer/mruby-shelf
  app = Example::Application.new.to_app

  # Currently, mruby-reeves depends on the fork of mruby-simplehttpserver (genya0407/mruby-simplehttpserver).
  # By adding mruby-reeves to your dependency, gemya0407/mruby-simplehttpserver is also added.
  serv = SimpleHttpServer.new(
    host: 'localhost',
    port: '3000',
    app: app,
  )
  serv.run
end
```

See [example.rb](./example/mrblib/example.rb) and [tests](./test/reeves/application.rb) for complehensive usage.

## Install

- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'genya0407/mruby-reeves'
end
```

## TODOs

- middleware
- default HTML sanitizing in ERB
- ... and other useful features.

## License

under the MIT License:
- see LICENSE file
