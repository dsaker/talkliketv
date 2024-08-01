# Include variables from the .envrc file
ifneq (,$(wildcard ./.envrc))
    include .envrc
endif

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

## copy-hooks: adds script to run before git push
copy-hooks:
	chmod +x scripts/hooks/*
	cp -r scripts/hooks .git/.

## expvar: add environment variable required for testing
expvar:
	eval $(cat .envrc)

## browser: open talkliketv in default browser
browser:
	python3 -m webbrowser https://${CLOUD_HOST_IP}.sslip.io/

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/web: run the cmd/web application
run/web:
	go run ./cmd/web -db-dsn=${TALKTV_DB_DSN} -smtp-username=${SMTP_USERNAME} -smtp-password=${SMTP_PASSWORD}

## run/api: run the cmd/api application
run/api:
	go run ./cmd/api -db-dsn=${TALKTV_DB_DSN} -smtp-username=${SMTP_USERNAME} -smtp-password=${SMTP_PASSWORD}

## run: run the docker container
run/docker:
	docker run -d --name talkliketv talkliketv:latest

## db/psql: connect to the database using psql
db/psql:
	psql ${TALKTV_DB_DSN}

## db/migrations/new name=$1: create a new database migration
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/migrations/up: apply all up database migrations
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${TALKTV_DB_DSN} up

## db/dump: pg_dump current talktv database
db/dump: confirm
	pg_dump --dbname=${TALKTV_DB_DSN} -F t >> internal/test/testdata/talktv_db_$(shell date +%s).tar


# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

audit:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	@echo 'Running tests...'

## audit/pipeline: tidy dependencies and format, vet and test all code (race on)
audit/pipeline:
	make audit
	go test -race -vet=off ./... -coverprofile=coverage.out -smtp-username=${SMTP_USERNAME} -smtp-password=${SMTP_PASSWORD}

## audit/local: tidy dependencies and format, vet and test all code (race off)
audit/local:
	make audit
	go test -vet=off ./... -coverprofile=coverage.out

## staticcheck:  detect bugs, suggest code simplifications, and point out dead code
staticcheck:
	staticcheck ./...

## lint: go linters aggregator
lint:
	 golangci-lint run ./...

## coverage
coverage:
	go tool cover -func coverage.out \
	| grep "total:" | awk '{print ((int($$3) > 80) != 1) }'

## coverage report
report:
	go test -vet=off ./... -coverprofile=coverage.out
	go tool cover -html=coverage.out -o cover.html

# ==================================================================================== #
# BUILD
# ==================================================================================== #

current_time = $(shell date +"%Y-%m-%dT%H:%M:%S%Z")
git_description = $(shell git describe --always --dirty --tags --long)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'

## build/api: build the cmd/api application
build/api:
	@echo 'Building cmd/api...'
	go build -ldflags=${linker_flags} -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/api ./cmd/api

## build/web: build the cmd/web application
build/web:
	@echo 'Building cmd/web...'
	go build -ldflags=${linker_flags} -o=./bin/web ./cmd/web
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/web ./cmd/web

## build/docker: build the talkliketv container
build/docker:
	@echo 'Building container...'
	docker build --build-arg LINKER_FLAGS=${linker_flags} --build-arg DB_DSN=${DOCKER_DB_DSN} --tag talkliketv:latest .

## build/pack: build the talkliketv container using build pack
build/pack:
	@echo 'Building container with buildpack'
	pack build talkliketv --env "LINKER_FLAGS=${linker_flags}" --env "DB_DSN=${DOCKER_DB_DSN}" --builder paketobuildpacks/builder-jammy-base

# ==================================================================================== #
# CLOUD
# ==================================================================================== #

## cloud/connect: connect to the cloud server
cloud/connect:
	ssh ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}

## cloud/deploy/api: deploy the web application to cloud
cloud/deploy/web:
	rsync -rP --delete ./bin/linux_amd64/web ./migrations ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~
	ssh -t ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP} 'migrate -path ~/migrations -database $TALKLIKETV_DB_DSN up'

## cloud/configure/web.service: configure the cloud systemd web.service file
cloud/configure/web.service:
	rsync -P ./remote/cloud/web.service ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~
	ssh -t ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP} '\
		sudo mv ~/web.service /etc/systemd/system/ \
		&& sudo systemctl enable web \
		&& sudo systemctl restart web \'

## cloud/configure/api.service: configure the cloud systemd api.service file
cloud/configure/api.service:
	rsync -P ./remote/cloud/api.service ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~
	ssh -t ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP} '\
		sudo mv ~/api.service /etc/systemd/system/ \
		&& sudo systemctl enable api \
		&& sudo systemctl restart api \'

## cloud/deploy/uploadcsv: deploy the scripts to cloud
cloud/uploadcsv:
	## rsync -rP --delete ./scripts/uploadcsv.py ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~/uploadcsv/
	## rsync -rP --delete ./scripts/csvfile ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~/uploadcsv
	scp /Users/dustysaker/Downloads/TheMannyS01E01.csv  ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~/uploadcsv

## cloud/configure/caddyfile: configure the cloud Caddyfile
cloud/configure/caddyfile:
	rsync -P ./remote/cloud/Caddyfile ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~
	ssh -t ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP} '\
		sudo mv ~/Caddyfile /etc/caddy/ \
		&& sudo systemctl reload caddy \'

## cloud/redeploy/web: builds and redeploys web to cloud
cloud/redeploy/web:
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/web ./cmd/web
	rsync -rP --delete ./bin/linux_amd64/web ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~
	ssh -t ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP} '\
		sudo systemctl restart web'


## cloud/redeploy/api: builds and redeploys api to cloud
cloud/redeploy/api:
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/api ./cmd/api
	rsync -rP --delete ./bin/linux_amd64/api ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP}:~
	ssh -t ${CLOUD_HOST_USERNAME}@${CLOUD_HOST_IP} '\
		sudo systemctl restart api'
