# Description
This image contains a simple bash script to dump all database of defined postgres server then upload them to S3 bucket.
This image is built specific for RDS postgres instances to overcome some RDS restrictions:
- We couldn't read role passwords
- We couldn't use pg_dumpall to easily dump all databases of the server at once because we couldn't read rdsadmin database. There're a pull request to support --exclude-database for pg_dumpall but it hasn't done yet.

# How it works
The bash script will iterate each line in file PGPASSDFILE, get a list of databases then dump each of them using `pg_dump`.
The script then compress the dump files, finally upload it to S3 bucket.

# Environments
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET

# [.pgpass](https://www.postgresql.org/docs/9.3/libpq-pgpass.html)
The user for each database must has the privileges to access all databases

