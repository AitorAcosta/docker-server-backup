# docker-server-backup

[![](https://images.microbadger.com/badges/image/tecnativa/server-backup.svg)](https://microbadger.com/images/tecnativa/server-backup "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/tecnativa/server-backup.svg)](https://microbadger.com/images/tecnativa/server-backup "Get your own version badge on microbadger.com")

Backup for docker containers PostgreSQL and volumes to S3

## Restore

Use the `restore` script to restore a file from S3.

Assuming  you ran the image with `-e BACKUP_S3_BUCKET=mybucket -e
BACKUP_S3_INSTANCE=myinstance` and you want to restore the file
`s3://mybucket/myinstance/some/file.tar.gz.enc` into `/root/restored` in the
container, just run:

    restore some/file.tar.gz.enc /root/restored

The file will be downloaded, decrypted and uncompressed for you. :wink:
