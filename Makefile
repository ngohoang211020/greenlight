include .envrc
# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/api: run the cmd/api application
run/api:
	@go run ./cmd/api db-dsn=${greenlight}
## db/psql: connect to the database using psql
db/psql:
	psql -U postgres -d greenlight -p 5432 -h localhost
## db/migrations/up: apply all up database migrations
db/migrations/up: confirm
	@migrate -path migrations -database postgresql://postgres:123456@localhost:5432/greenlight?sslmode=disable up
## db/migrations/down: apply all up database migrations
db/migrations/down: confirm
	@migrate -path migrations -database postgresql://postgres:123456@localhost:5432/greenlight?sslmode=disable down
## db/migrations/new name=$1: create a new database migration
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}
# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #
## audit: tidy dependencies and format, vet and test all code
audit:
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

## build/api: build the cmd/api application
build/api:
	@echo 'Building cmd/api... into files containing machine code(executable binary)'
	go build -ldflags='-s' -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags='-s' -o=./bin/linux_amd64/api ./cmd/api
.PHONY: run/api help confirm db/migrations/down db/migrations/new db/migrations/up db/psql audit vendor build/api
