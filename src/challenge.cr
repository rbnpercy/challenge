require "./challenge/*"
require "kemal"
require "./auth"

module Challenge

  get "/" do
    render "src/challenge/views/home.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/:name" do |env|
    name = env.params.url["name"]
    render "src/challenge/views/hello.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/auth/login" do
    render "src/challenge/views/login.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/auth/callback" do |env|
    code = env.params.query["code"]
    jwt = Auth.get_auth_token(code)
    env.response.headers["Authorization"] = "Bearer #{jwt}"  # Set the Auth header with JWT.

    user = env.response.headers.inspect

    # env.redirect "/success"

    render "src/challenge/views/callback.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/success" do |env|
    heads = env.response.headers.inspect
    render "src/challenge/views/success.ecr", "src/challenge/views/layouts/main.ecr"
  end


  Kemal.config.port = 6969
  Kemal.run

end
