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
