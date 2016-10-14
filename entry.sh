#!/bin/sh

set -e
set -x
set -o pipefail

[ -z "${MYSQL_HOST}" ] && { echo "Environment variable MYSQL_HOST is mandatory"; exit 1; }
[ -z "${MYSQL_PORT}" ] && { echo "Environment variable MYSQL_PORT is mandatory"; exit 1; }
[ -z "${MYSQL_USER}" ] && { echo "Environment variable MYSQL_USER is mandatory"; exit 1; }
[ -z "${MYSQL_PASSWORD+x}" ] && { echo "Environment variable MYSQL_PASSWORD is mandatory"; exit 1; }
[ -z "${BUCKET}" ] && { echo "Environment variable BUCKET is mandatory"; exit 1; }

[ ! -z "${MYSQL_PASSWORD}" ] && password_arg="-p${MYSQL_PASSWORD}"
if [ -z "${DB_NAME}" ]; then
  db_arg='--all-databases'
else
  db_arg="--databases ${DB_NAME}"
fi

if [ "$1" == "backup" ]; then
  DATETIME=`date +"%Y%m%dT%H%M%z"`
  FILE="$FILENAME-$DATETIME.sql.gz"

  mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${password_arg} ${db_arg} \
  | gzip -9 -c \
  | aws s3 cp - --region="${REGION:-us-east-1}" "s3://$BUCKET/$FILE"
elif [ "$1" == "restore" ]; then
  [ ! -z "$2" ] && FILE="$2" || { echo "Must specify the file when restoring" ; exit 1; }

  aws s3 cp --region="${REGION:-us-east-1}" "s3://$BUCKET/$FILE" - \
  | gunzip \
  | mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${password_arg} ${DB_NAME}
else
  echo "Unrecognized command: $1"
  exit 1
fi
