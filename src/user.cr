require "jwt"
require "json"

module User
  extend self

  @@verify_key = "Gmfixos1ZTCna4wbH0txtEIXgTZZC3oBwfpe1Iq9S-QrUukXcgVoI1dW7JLnBfkB"

  def authorised?(user)
    token = user
    payload, header = JWT.decode(token, @@verify_key, "HS256")
    roles = payload["app_metadata"].to_s
    rs = roles.includes?("member")
    puts rs

    return
  end

end

# User.authorised?("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX21ldGFkYXRhIjp7fSwiYXBwX21ldGFkYXRhIjp7InJvbGVzIjoibWVtYmVyIn0sImVtYWlsIjoicm9iaW5AcGVyY3kudGVzdCIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiaXNzIjoiaHR0cHM6Ly9yYmluLmV1LmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw1OWNhNThlZTc1ZWE1ZDQ1MTRhYzU1YmEiLCJhdWQiOiJBdTJ6Q001amYwNzBlVFp6M0xHYWVMMkpDeTBWTmVwUSIsImlhdCI6MTUwNjYyMDg0NywiZXhwIjoxNTA2NjU2ODQ3fQ.C4xepiw-V8WTT9j76QMTRGVY4Yf0kl0LtL2x_-OTGzc")

# {"user_metadata" => {}, "app_metadata" => {"roles" => "member"}, "email" => "robin@percy.test", "email_verified" => false, "iss" => "https://rbin.eu.auth0.com/", "sub" => "auth0|59ca58ee75ea5d4514ac55ba", "aud" => "Au2zCM5jf070eTZz3LGaeL2JCy0VNepQ", "iat" => 1506620847, "exp" => 1506656847}
