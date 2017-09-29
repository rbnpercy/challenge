require "./challenge/*"
require "kemal"
require "kemal-session"
require "./auth"
require "./user"
require "./challenge/models/challenge"

module Challenger

  Kemal::Session.config do |config|
    config.cookie_name = "sess_id"
    config.secret = "3c74e7e506f9cfdb23cc22247d37bc21a9f04d296140f3cc0193dbb94776a3dec42fb0f3a1056ae8c0df346d94f34d6b9f48d1465a05b43d4bee0b616738bdf5"
    config.gc_interval = 1.minutes # 2 minutes
  end

  class UserStorableObject
    JSON.mapping({
      id_token: String
    })

    include Kemal::Session::StorableObject

    def initialize(@id_token : String); end
  end


######  BEGIN ROUTES FOR APP & AUTH ######
  get "/" do
    render "src/challenge/views/home.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/auth/login" do
    render "src/challenge/views/login.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/auth/callback" do |env|
    code = env.params.query["code"]
    jwt = Auth.get_auth_token(code)
    env.response.headers["Authorization"] = "Bearer #{jwt}"  # Set the Auth header with JWT.

    user = UserStorableObject.new(jwt)
    env.session.object("user", user)

    env.redirect "/success"
  end

  get "/success" do |env|
    user = env.session.object("user").as(UserStorableObject)
    env.response.headers["Authorization"] = "Bearer #{user.id_token}"

    heads = env.response.headers.inspect

    render "src/challenge/views/success.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/auth/logout" do |env|
    env.session.destroy

    render "src/challenge/views/logout.ecr", "src/challenge/views/layouts/main.ecr"
  end


###### CHALLENGES ROUTES
  get "/challenges" do |env|
    user = env.session.object("user").as(UserStorableObject)
    env.response.headers["Authorization"] = "Bearer #{user.id_token}"

    heads = env.response.headers.inspect

    challenges = Challenge.all("ORDER BY id DESC")


    render "src/challenge/views/challenges/index.ecr", "src/challenge/views/layouts/main.ecr"
  end

  get "/challenges/:id" do |env|
    # GET Challenge from Database - with :id

    if challenge = Challenge.find env.params.url["id"]
      render("src/challenge/views/challenges/details.ecr", "src/challenge/views/layouts/main.ecr")
    else
      "Challenge with ID #{env.params.url["id"]} Not Found"
      env.redirect "/challenges"
    end

    # render "src/challenge/views/challenges/details.ecr", "src/challenge/views/layouts/main.ecr"
  end


  before_get "/challenges/new" do |env|
    user = env.session.object("user").as(UserStorableObject)

    authy = User.authorised?(user.id_token)
    raise "Unauthorized" unless authy = true
  end

  get "/challenges/new" do |env|

    render "src/challenge/views/challenges/new.ecr", "src/challenge/views/layouts/main.ecr"
  end

######  END OF ROUTES  ######

  error 500 do

    render "src/challenge/views/error/auth.ecr", "src/challenge/views/layouts/main.ecr"
  end

  Kemal.config.port = 6969
  Kemal.run

end
