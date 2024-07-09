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
# PRODUCTION
# ==================================================================================== #

production_host_ip = "164.92.111.120"

## production/connect: connect to the production server
production/connect:
	ssh talkliketv@${production_host_ip}

## production/deploy/api: deploy the api to production
production/deploy/web:
	rsync -rP --delete ./bin/linux_amd64/web ./migrations talkliketv@${production_host_ip}:~
	ssh -t talkliketv@${production_host_ip} 'migrate -path ~/migrations -database $TALKLIKETV_DB_DSN up'

## production/configure/web.service: configure the production systemd web.service file
production/configure/web.service:
	rsync -P ./remote/production/web.service talkliketv@${production_host_ip}:~
	ssh -t talkliketv@${production_host_ip} '\
		sudo mv ~/web.service /etc/systemd/system/ \
		&& sudo systemctl enable web \
		&& sudo systemctl restart web \'

## production/configure/api.service: configure the production systemd api.service file
production/configure/api.service:
	rsync -P ./remote/production/api.service talkliketv@${production_host_ip}:~
	ssh -t talkliketv@${production_host_ip} '\
		sudo mv ~/api.service /etc/systemd/system/ \
		&& sudo systemctl enable api \
		&& sudo systemctl restart api \'

## production/deploy/uploadcsv: deploy the scripts to production
production/uploadcsv:
	## rsync -rP --delete ./scripts/uploadcsv.py talkliketv@${production_host_ip}:~/uploadcsv/
	## rsync -rP --delete ./scripts/csvfile talkliketv@${production_host_ip}:~/uploadcsv
	scp /Users/dustysaker/Downloads/TheMannyS01E01.csv  talkliketv@${production_host_ip}:~/uploadcsv

## production/configure/caddyfile: configure the production Caddyfile
production/configure/caddyfile:
	rsync -P ./remote/production/Caddyfile talkliketv@${production_host_ip}:~
	ssh -t talkliketv@${production_host_ip} '\
		sudo mv ~/Caddyfile /etc/caddy/ \
		&& sudo systemctl reload caddy \'

## production/redeploy/web: builds and redeploys web to production
production/redeploy/web:
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/web ./cmd/web
	rsync -rP --delete ./bin/linux_amd64/web talkliketv@${production_host_ip}:~
	ssh -t talkliketv@${production_host_ip} '\
		sudo systemctl restart web'


## production/redeploy/api: builds and redeploys api to production
production/redeploy/api:
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/api ./cmd/api
	rsync -rP --delete ./bin/linux_amd64/api talkliketv@${production_host_ip}:~
	ssh -t talkliketv@${production_host_ip} '\
		sudo systemctl restart api'
