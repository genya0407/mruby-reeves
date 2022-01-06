def self.env_for(path_and_query, opts = {})
  uri = HTTP::Parser.new.parse_url(path_and_query)

  env = {
    method: 'GET',
    host: uri.host || 'example.org',
    port: (uri.port || 80).to_s,
    query_string: uri.query || '',
    shelf_url_scheme: uri.schema || 'http',
    path: uri.path || '/',
  }.merge(opts)

  {
    Shelf::REQUEST_METHOD => env.delete(:method).to_s.upcase,
    Shelf::SERVER_NAME => env.delete(:host),
    Shelf::SERVER_PORT => env.delete(:port),
    Shelf::QUERY_STRING => env.delete(:query_string),
    Shelf::PATH_INFO => env.delete(:path),
    Shelf::HTTPS => env[:shelf_url_scheme] == 'https' ? 'on' : 'off',
    Shelf::SHELF_URL_SCHEME => env.delete(:shelf_url_scheme),
  }.merge(env)
end

assert("Reeves::Application / routing") do
  app = Class.new(Reeves::Application) do
    get '/get_1' do
      render raw: 'ok get'
    end

    post '/post_1' do
      render raw: 'ok post'
    end

    put '/put_1' do
      render raw: 'ok put'
    end

    delete '/delete_1' do
      render raw: 'ok delete'
    end
  end.new.to_app

  assert_equal(['ok get'], app.call(env_for('/get_1', method: :get))[2])
  assert_equal(['ok post'], app.call(env_for('/post_1', method: :post))[2])
  assert_equal(['ok put'], app.call(env_for('/put_1', method: :put))[2])
  assert_equal(['ok delete'], app.call(env_for('/delete_1', method: :delete))[2])
end

assert("Reeves::Application / routing / same path different method") do
  app = Class.new(Reeves::Application) do
    get '/hoge' do
      render raw: 'ok get'
    end

    post '/hoge' do
      render raw: 'ok post'
    end
  end.new.to_app

  assert_equal(['ok get'], app.call(env_for('/hoge'))[2])
  assert_equal(['ok post'], app.call(env_for('/hoge', method: :post))[2])
end

assert("Reeves::Application / params") do
  app = Class.new(Reeves::Application) do
    get '/query' do
      render raw: "ok #{params['query_param1']}"
    end

    post '/path1/:path_param1' do
      render raw: "ok #{params['path_param1']}"
    end
  end.new.to_app

  assert_equal(['ok hoge'], app.call(env_for('/query?query_param1=hoge'))[2])
  assert_equal(['ok fuga'], app.call(env_for('/path1/fuga', method: :post))[2])
end

assert("Reeves::Application / params / invalid path param") do
  assert_raise_with_message_pattern(RuntimeError, 'Invalid path pattern: *') do
    Class.new(Reeves::Application) do
      post '/path1/:path_param1/invalid_tail' do
        render raw: "ok #{params['path_param1']}"
      end
    end.new.to_app  
  end
end

assert("Reeves::Application / request") do
  app = Class.new(Reeves::Application) do
    post '/data' do
      render raw: "ok #{request.body}"
    end
  end.new.to_app

  # fix genya0407.request_body after Shelf supports request body officialy.
  assert_equal(
    ['ok this is body'],
    app.call(env_for('/data', method: 'post', 'genya0407.request_body' => 'this is body'))[2]
  )
end

assert("Reeves::Application / request / json") do
  app = Class.new(Reeves::Application) do
    post '/data' do
      render raw: "ok #{request.json['key_1']}"
    end
  end.new.to_app

  # fix genya0407.request_body after Shelf supports request body officialy.
  assert_equal(
    ['ok value_1'],
    app.call(env_for('/data', method: 'post', 'genya0407.request_body' => JSON.dump(key_1: 'value_1')))[2]
  )
end

assert("Reeves::Application / request / headers") do
  app = Class.new(Reeves::Application) do
    get '/header' do
      render raw: "ok #{request.headers['header_1']}"
    end
  end.new.to_app

  # fix genya0407.request_body after Shelf supports request body officialy.
  assert_equal(
    ['ok value_1'],
    app.call(env_for('/header', method: :get, 'header_1' => 'value_1'))[2]
  )
end

assert("Reeves::Application / render / body") do
  app = Class.new(Reeves::Application) do
    get '/raw' do
      render raw: 'ok'
    end

    get '/json' do
      render json: { hoge: 'fuga' }
    end

    get '/erb' do
      @some_instance_variable = 'hogehogenya'
      Tempfile.open('erb-test') do |file|
        file.write('<p><%= @some_instance_variable %></p>')
        render erb: file.path
      end
    end
  end.new.to_app

  assert_equal(['ok'], app.call(env_for('/raw'))[2])
  assert_equal([JSON.dump(hoge: 'fuga')], app.call(env_for('/json'))[2])
  assert_equal(['<p>hogehogenya</p>'], app.call(env_for('/erb'))[2])
end

assert("Reeves::Application / render / status") do
  app = Class.new(Reeves::Application) do
    get '/default' do
      render raw: 'success'
    end

    get '/bad_request' do
      render status: 400, raw: 'bad request'
    end
  end.new.to_app

  assert_equal(200, app.call(env_for('/default'))[0])
  assert_equal(400, app.call(env_for('/bad_request'))[0])
end

assert("Reeves::Application / render / headers") do
  app = Class.new(Reeves::Application) do
    get '/headers' do
      render raw: 'success', headers: { 'Content-Type' => 'application/json' }
    end
  end.new.to_app

  assert_equal({ 'Content-Type' => 'application/json' }, app.call(env_for('/headers'))[1])
end

assert("Reeves::Application / redirect_to") do
  app = Class.new(Reeves::Application) do
    get '/redirect' do
      redirect_to '/path/to/redirect'
    end
  end.new.to_app

  status, headers, body = app.call(env_for('/redirect'))
  assert_equal(303, status)
  assert_equal({ 'Location' => '/path/to/redirect' }, headers)
  assert_equal(['You are redirected to "/path/to/redirect".'], body)
end

assert("Reeves:Application / helper") do
  app = Class.new(Reeves::Application) do
    helper do
      def awesome_helper
        'This is helper retval!'
      end
    end

    get '/' do
      render raw: awesome_helper
    end
  end.new.to_app

  assert_equal(['This is helper retval!'], app.call(env_for('/'))[2])
end

assert("Reeves::Application / send_file") do
  Tempfile.open('sendfile') do |file|
    file.write 'This is file content'
    file.flush

    app = Class.new(Reeves::Application) do
      get '/' do
        send_file file.path
      end
    end.new.to_app

    assert_equal(['This is file content'], app.call(env_for('/'))[2])
  end
end

