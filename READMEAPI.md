# talkliketv api

talkliketv is a simple web application to learn a language by using subtitle from popular tv shows

# Dependencies

- Go version 1.21

# Start locally

`make run/api`

# Register User

`BODY='{"name": "newuser", "password": "password12", "email": "newuser@email.com", "language": "Spanish"}'
curl -i -d "$BODY" localhost:4001/v1/users`

# Get Token

`BODY='{"email": "localuser@email.com", "password": "password12"}' 
curl -i -d "$BODY" localhost:4001/v1/tokens/authentication`

# ChooseMovie

`BODY='{"movie_id": 1}'
curl --request PATCH -i -H "Authorization: Bearer [bearer_token]" -d "$BODY" localhost:4001/v1/movies/choose`

# GetMovies

`curl -i -H "Authorization: Bearer 2U2A22WX3SRGW5M32WPBCZHHSY" localhost:4001/v1/movies`

# PhraseUpdate

`BODY='{"movie_id": 1, "phrase_id": 2}'
curl --request POST -i -H "Authorization: Bearer SPGDKSFQHXPBZGKBTV6LAGBGLQ" -d "$BODY" localhost:4001/v1/phrases/correct`