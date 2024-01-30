# greenlight

1. Create Migrate file

migrate create -seq -ext=.sql -dir=./migrations filename

2. Migrate up -Using makefile
make migrateup
3. Migrate down 
make migratedown