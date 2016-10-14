# mysql-backup-to-s3

Backs up and restores MySQL instances. Works with IAM Roles or explicit credentials.

## Backup

Usage:
```
docker run --rm --link some_mysql_container:mysql \
           -e AWS_ACCESS_KEY_ID=... -e AWS_SECRET_ACCESS_KEY=... \
           -e MYSQL_HOST=mysql -e BUCKET=my-aws-bucket -e DB_NAME='db1 db2' \
           elementar/mysql-backup-to-s3
```

It will perform a backup of the specified databases using `mysqldump`, then compress using
`gzip` and upload to S3.

## Restore

Usage:
```
docker run --rm --link some_mysql_container:mysql \
           -e BUCKET=my-aws-bucket -e AWS_ACCESS_KEY_ID=... -e AWS_SECRET_ACCESS_KEY=... \
           -e MYSQL_HOST=mysql -e MYSQL_USER=root -e MYSQL_PASSWORD=abc \
           FILE='mysql-backup-20161012T1803+0000.sql.gz' \
           elementar/mysql-backup-to-s3 restore
```

It will download the backup file from S3, decompress using `gunzip`, then load into the MySQL instance
using the `mysql` command-line interface.
