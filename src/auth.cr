require "http/client"
require "json"

module Auth
  extend self

  class Token
    JSON.mapping(
      access_token: String,
      id_token: String,
      expires_in: Int32,
      token_type: String,
    )
  end

  def get_auth_token(id_code)
    id = id_code

    uri = URI.parse("https://[YOUR_DOMAIN].auth0.com/oauth/token")

    request = HTTP::Client.post(uri,
      headers: HTTP::Headers{"content-type" => "application/json"},
      body: "{\"grant_type\":\"authorization_code\",\"client_id\": \"[CLIENT_ID]\",\"client_secret\": \"[CLIENT_SECRET]\",\"code\": \"#{id}\",\"redirect_uri\": \"http://localhost:6969/auth/callback\"}")

    response = request.body

    res = get_jwt(response)
    return res
  end

  def get_jwt(auth_code)
    auth = auth_code

    value = Token.from_json(%(#{auth}))
    jwt = value.id_token

    return jwt
  end

end
