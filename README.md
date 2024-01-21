# talkliketv

TalkLikeTV is a revolutionary language learning application designed to address the shortcomings of other language apps. Unlike other platforms, TalkLikeTV focuses on bridging the gaps in native-to-foreign language translation and provides an immersive experience by incorporating authentic native speakers conversing at real speeds and tones.

With TalkLikeTV, you can elevate your language skills to sound and comprehend like a local. The unique approach involves learning from the subtitles of TV shows and then listening to the episodes at your convenience. By translating from your native language to the spoken subtitles of a TV show, you not only grasp how native speakers communicate but also enhance your ability to understand the actors in the show.

This innovative method not only prepares you to speak the language naturally but also boosts your confidence in using it. Say goodbye to traditional language learning hurdles and embrace a more effective and enjoyable language acquisition experience with TalkLikeTV.

# Dependencies

- Go version 1.21

# Make

To list available make commands

`make help`

# Startup Locally

To run locally

`docker pull postgres
docker run -d -P -p 127.0.0.1:5433:5432 -e POSTGRES_PASSWORD="password" --name talkliketvpg postgres
echo "export TALKTV_DB_DSN=postgresql://postgres:password@localhost:5433/postgres?sslmode=disable" >> .envrc
make db/migrations/up
make run/web
make run/api`

# Build

To build the web application
`make build/web`

To build the api
`make build/api`

# Extract srt file from mkv files

download mkvextract tool -> https://mkvtoolnix.download/downloads.html

find srt track of language you would like to extract 
`mkvinfo mkvfile.mkv`
and extract
`mkvextract mkvfile.mkv tracks 5:[Choose Title].[Choose Language].srt`

# To Do

GetAllMovies when not signed in