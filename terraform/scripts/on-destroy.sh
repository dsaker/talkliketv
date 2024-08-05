pg_dump --dbname=postgres://talkliketv:talkliketv_password@localhost/talkliketv?sslmode=disable -F p >> talktv_db_$(date +%s).sql
gsutil cp talktv_db_*.sql gs://talkliketv-sb