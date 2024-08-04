pg_dump --dbname=postgres://${db_user}:${db_password}@localhost/${db_name}?sslmode=disable -F t >> talktv_db_$(date +%s).sql
gsutil cp talktv_db_*.sql gs://${module_bucket_name}