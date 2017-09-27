require "http/client"
require "json"

class Token
  JSON.mapping(
    access_token: String,
    id_token: String,
    expires_in: Int32,
    token_type: String,
  )
end

uri = URI.parse("https://rbin.eu.auth0.com/oauth/token")

id_code = "e-lk--JSaSU3uPqA"
request = HTTP::Client.post(uri,
  headers: HTTP::Headers{"content-type" => "application/json"},
  body: "{\"grant_type\":\"authorization_code\",\"client_id\": \"Au2zCM5jf070eTZz3LGaeL2JCy0VNepQ\",\"client_secret\": \"Gmfixos1ZTCna4wbH0txtEIXgTZZC3oBwfpe1Iq9S-QrUukXcgVoI1dW7JLnBfkB\",\"code\": \"#{id_code}\",\"redirect_uri\": \"http://localhost:3000/callback\"}")

response = request.body
value = Token.from_json(%(#{response}))

res = value.id_token
puts res
