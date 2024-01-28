migrateup:
	migrate -path migrations -database postgresql://postgres:123456@localhost:5432/greenlight?sslmode=disable up
migratedown:
	migrate -path migrations -database postgresql://postgres:123456@localhost:5432/greenlight?sslmode=disable down
.PHONY: migrateup