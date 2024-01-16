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
curl --request PATCH -i -H "Authorization: Bearer EQIO77KQ2GJGOB6WSTQVU3FH2M" -d "$BODY" localhost:4001/v1/movies/choose`

# GetMovies

`curl -i -H "Authorization: Bearer EQIO77KQ2GJGOB6WSTQVU3FH2M" localhost:4001/v1/movies`

# PhraseUpdate

`BODY='{"movie_id": 1, "phrase_id": 2}'
curl --request POST -i -H "Authorization: Bearer EQIO77KQ2GJGOB6WSTQVU3FH2M" -d "$BODY" localhost:4001/v1/phrase/correct`