#!/usr/bin/env bash

set -euo pipefail

export readonly PGPASSFILE="${PGPASSFILE:-/root/.pgpass}"
export readonly _UPLOAD_DIR="s3://${S3_BUCKET}/$(date +%Y)/$(date +%m)/$(date +%d)"
export readonly _DUMP_DIR="${DUMP_DIR:-/}"


if [[ ! -r $PGPASSFILE ]]; then
  echo "File $PGPASSFILE doesn't exist or is not readable"
  exit 1
fi

function get_all_db() {
  local _hostname=$1    ; shift
  local _port=$1        ; shift
  local _username=$1    ; shift

  local _dbs=$(psql \
    -h $_hostname \
    -p $_port \
    -U $_username \
    --tuples-only \
    -w \
    postgres \
    -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'rdsadmin' AND datname != 'postgres';")

  echo "$_dbs"
}

# .pgpass format
# address:port:database:user:password
# address, port and database could be wildcard

while read -r line; do
  IFS=: read _hostname _port _database _username _ <<< $line

  _backup_dir="${_DUMP_DIR}/${_hostname}"
  mkdir -p $_backup_dir

  while read -r _db; do
    printf "Dump database $_db of server ${_hostname} to folder ${_backup_dir}"
    pg_dump \
      -h $_hostname \
      -p $_port \
      -U $_username \
      $_db \
      >> ${_backup_dir}/${_db}.sql
  done <<< "$(get_all_db $_hostname $_port $_username)"

  echo "Compress folder $_backup_dir"
  tar \
    cvfz \
    ${_hostname}.gzip \
    $_backup_dir

  echo "Upload file ${_hostname}.gzip to bucket ${S3_BUCKET}"
  aws s3 cp ${_hostname}.gzip ${_UPLOAD_DIR}/${_hostname}.gzip

  echo "Cleanup dump file"
  rm -rf $_backup_dir
  rm -f ${_hostname}.gzip

done < "$PGPASSFILE"
