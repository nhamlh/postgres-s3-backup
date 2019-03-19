# Description
This image contains a simple bash script to dump all database of defined postgres server then upload them to S3 bucket.

# How it works
The bash script will iterate each line in file .pgpass, dump the server using `pg_dumpall`. Notice that I've use `--no-role-passwords` because I developed this image to work with my specific usecase: backing up RDS servers, which doesn't allow users to read roles' password.

# Environments
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET

# [.pgpass](https://www.postgresql.org/docs/9.3/libpq-pgpass.html)
User for each database must has the privileges to access all databases

