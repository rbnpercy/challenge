require "json"

class Token
  JSON.mapping(
    access_token: String,
    id_token: String,
    expires_in: Int32,
    token_type: String,
  )
end

value = Token.from_json(%({"access_token":"ijAHPX_fTME3f2G8",
  "id_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ik1qQTBSRGd6T0RFek16TTFOREEwTnpFd1JURkdNamMzUkRNek5rSTJOemMwTWtJNE1ERkZOZyJ9.eyJlbWFpbCI6InJvYmluQHBlcmN5LnRlc3QiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vcmJpbi5ldS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NTljYTU4ZWU3NWVhNWQ0NTE0YWM1NWJhIiwiYXVkIjoiQXUyekNNNWpmMDcwZVRaejNMR2FlTDJKQ3kwVk5lcFEiLCJpYXQiOjE1MDY0NDAxODUsImV4cCI6MTUwNjQ3NjE4NX0.VbOrMD7uPoJ-vcbwezmVKJJnClgiMa3nzDc8scmUZgJxQ2JR5y6v2lmz0c_m8sGzC9tDCMy4S8gjYwxSLTkjY-L7SjAKMvnzXVVp26_1YMmLd2L8a9SQ9GbcIil5vHaM0-afFWkvjiuQjNcXv7gfmfwxhJAslYBbbXDZSxEzkcakjunq6Zp4MSpRl_keY7JqvjKbqhGirZiwZIUW7IP1bnk4pH36pD4V8VS6xx3FUCCMvYWC-807nU2oEZlUz_g3AWpYa67p37ANFrIZ5DkgLrvrOJYVwj4KvH8O-t01aAoASe1yL5gXMCPvNyxFEkwRz_o0GcTKxwXJI-0Lnenftg",
  "expires_in":86400,
  "token_type":"Bearer"
}))

res = value.id_token
puts res
