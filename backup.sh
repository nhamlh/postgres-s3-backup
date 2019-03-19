#!/usr/bin/env bash

set -euo pipefail

export readonly PGPASSFILE="${PGPASSFILE:-~/.pgpass}"
export readonly _TIMESTAMP="$(date +%Y%m%d)"
export readonly _UPLOAD_DIR="s3://${S3_BUCKET}/$(date +%Y)/$(date +%m)"


if [[ ! -r $PGPASSFILE ]]; then
  echo "File $PGPASSFILE doesn't exist or is not readable"
  exit 1
fi

# .pgpass format
# address:port:database:user:password
# address, port and database could be wildcard

while read -r line; do
  IFS=: read _HOSTNAME _PORT _DATABASE _USERNAME _PASSWORD <<< $line

  _backup_file="${_HOSTNAME}-${_TIMESTAMP}.sql"

  echo "Dump all databases of server ${_HOSTNAME} to ${_backup_file}"
  pg_dumpall \
    -h $_HOSTNAME \
    -p $_PORT \
    -U $_USERNAME \
    -w \
    --no-role-passwords \
    > ${_backup_file} \
    && tar \
      cvfz \
      ${_backup_file}.gzip \
      $_backup_file

  echo "Upload file ${_backup_file}.gzip to bucket ${S3_BUCKET}"
  aws s3 cp ${_backup_file}.gzip ${_UPLOAD_DIR}/$_backup_file.gzip

  echo "Cleanup dump file"
  rm -f $_backup_file
  rm -f ${_backup_file}.gzip

done < "$PGPASSFILE"
