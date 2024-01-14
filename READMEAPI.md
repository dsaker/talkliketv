# talkliketv api

talkliketv is a simple web application to learn a language by using subtitle from popular tv shows

# Dependencies

- Go version 1.21

# Start locally

`make run/api`

# Register User

`BODY='{"name": "LocalUser", "password": "password12", "email": "localuser@email.com", "language": "Spanish"}'
curl -i -d "$BODY" localhost:4001/v1/users`

# Get Token

`BODY='{"email": "localuser@email.com", "password": "password12"}' 
curl -i -d "$BODY" localhost:4001/v1/tokens/authentication`

# ChooseMovie

`BODY='{"movie_id": "1"}'
curl --request PATCH -i -H "Authorization: Bearer [bearer_token]" -d "$BODY" localhost:4001/v1/movies/choose`

