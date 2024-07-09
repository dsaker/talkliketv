# talkliketv api

talkliketv is a simple web application to learn a language by using subtitles from popular tv shows

# Dependencies

- Go version 1.21

# Start locally

`make run/api`

# HealthCheck

`curl -i localhost:4001/v1/healthcheck`

# Register User

`BODY='{"name": "newuser11", "password": "password12", "email": "newuser11@email.com", "language": "Spanish"}'
curl -i -d "$BODY" localhost:4001/v1/users`


# Get Token

`BODY='{"email": "localuser@email.com", "password": "password12"}' 
curl -i -d "$BODY" localhost:4001/v1/tokens/authentication`

# Store Token In TOKEN

`BODY='{"email": "localuser@email.com", "password": "password12"}'
TOKEN=$(curl -d "$BODY" localhost:4001/v1/tokens/authentication | jq -r '.authentication_token.token')
`

# ChooseMovie

`BODY='{"movie_id": 1}'
curl --request PATCH -i -H "Authorization: Bearer $TOKEN" -d "$BODY" localhost:4001/v1/movies/choose`

# GetMovies

`curl -i -H "Authorization: Bearer $TOKEN" localhost:4001/v1/movies`

# PhraseCorrect

`BODY='{"movie_id": 1, "phrase_id": 2}'
curl --request POST -i -H "Authorization: Bearer $TOKEN" -d "$BODY" localhost:4001/v1/phrase/correct`

# ListAllMoviesTextSearch

`curl -i -H "Authorization: Bearer $TOKEN" "localhost:4001/v1/movies?title=nothing&page_size=10"`

# ListAllMoviesNoText

`curl -i -H "Authorization: Bearer $TOKEN" "localhost:4001/v1/movies?page_size=5&sort=-num_subs"`

# Activate User
`BODY='{"token": "PQR7I6SB6OGKDSWK4ZMQZKWWFQ"}'
curl --request PUT -i -d "$BODY" localhost:4001/v1/users/activated`

# Password-Reset Request
`BODY='{"email": "newuser6@email.com"}'
curl --request POST -i -d "$BODY" localhost:4001/v1/tokens/password-reset`

# Change Password
`BODY='{"token": "26LDI3W4LV2POBDVYL3MCLC3VY", "password": "new_password"}'
curl --request PUT -i -d "$BODY" localhost:4001/v1/users/password`

# Download Mp3
`BODY='{"token": "26LDI3W4LV2POBDVYL3MCLC3VY", "password": "new_password"}'
curl --request PUT -i -d "$BODY" localhost:4001/v1/users/password`
