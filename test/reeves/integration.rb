assert 'request body' do
  begin
    app_class = Class.new(Reeves::Application) do
      post '/echo' do
        render json: { raw: request.body, data: request.json }
      end
    end
    server = SimpleHttpServer.new(
      host: 'localhost',
      port: '3000',
      run_gc_per_request: true,
      app: app_class.new.to_app,
    )

    pid = fork { server.run }

    data = { hogehoge: 'fugafuga' }
    json_req_body = JSON.dump(data)

    raw_res = `curl -si -XPOST localhost:3000/echo -d '#{json_req_body}'`
    HTTP::Parser.new.parse_response(raw_res) do |res|
      assert_equal(JSON.dump(raw: json_req_body, data: data), res.body)
    end
  ensure
    Process.kill :TERM, pid
  end
end

