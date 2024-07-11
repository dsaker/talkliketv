# talkliketv

TalkLikeTV is a language learning application designed to address the shortcomings of other language apps by incorporating authentic native speakers conversing at real speeds and tones.

The unique approach involves learning from the subtitles of TV shows and then watching the episodes at your convenience. By translating from your native language to the spoken subtitles of a TV show, you not only grasp how native speakers communicate but also enhance your ability to understand the actors in the show.

You can use a tab separated file to upload any phrases you want to learn using the bash script `./scripts/shell/uploadtsv.sh`. 

The books [Let's Go](https://lets-go.alexedwards.net/) and [Let's Go Further](https://lets-go-further.alexedwards.net/) were used heavily in creating this application. I would highly recommend them to anyone wanting to learn Golang.

### Make

To list available make commands

`make help`

### Create Mailtrap account

- Create an account at [Mailtrap](https://mailtrap.io/)
- Create an inbox in [Email Testing](https://mailtrap.io/inboxes)
- Run `cp .envrc.default .envrc`
- Copy the username and password into SMTP_USERNAME and SMTP_PASSWORD in .envrc

### Startup Locally

```
docker pull postgres
docker run -d -P -p 127.0.0.1:5433:5432 -e POSTGRES_PASSWORD="password" --name talkliketvpg postgres
echo "export TALKTV_DB_DSN=postgresql://postgres:password@localhost:5433/postgres?sslmode=disable" >> .envrc
make db/migrations/up
make run/web
make run/api
```

### Testing

Before running tests locally run 
```
make expvar
```

### Build

To build the web application
```
make build/web
```

To build the api
```
make build/api
```

### Extract srt file from mkv files

download mkvextract tool -> https://mkvtoolnix.download/downloads.html

find srt track of language you would like to extract 
`mkvinfo mkvfile.mkv`
and extract
`mkvextract mkvfile.mkv tracks 5:[Choose Title].[Choose Language].srt`

### To Do

- GetAllMovies when not signed in
- delete account
- password reset web
- add comments
- connect to google language translator

### Setup Google Cloud Translate

https://cloud.google.com/translate/docs/setup
