# docker-server-backup

[![](https://images.microbadger.com/badges/image/tecnativa/server-backup.svg)](https://microbadger.com/images/tecnativa/server-backup "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/tecnativa/server-backup.svg)](https://microbadger.com/images/tecnativa/server-backup "Get your own version badge on microbadger.com")

Backup for docker containers PostgreSQL and volumes to S3

## Restore

Use the `restore` script to restore a file from S3.

Assuming you ran the image with `-e BACKUP_S3_BUCKET=mybucket -e
BACKUP_S3_INSTANCE=myinstance --name backup_container` and you want to restore
the file `s3://mybucket/myinstance/some/file.tar.gz.enc` into `/root/restored`
in the container, just run:

    docker exec -it backup_container restore some/file.tar.gz.enc /root/restored

If the container was run by Docker Compose (assuming the service was called
`backup`):

    docker-compose exec backup restore some/file.tar.gz.enc /root/restored

If you want to extract the restored files to the host, use a shared volume or
`docker cp`.

The file will be downloaded, decrypted and uncompressed for you. :wink:

## Configuring Amazon for backups

### Get an S3 bucket

It's common to want a bucket per project, divided in folders per server.

If current project has no bucket yet, go to [S3 Manager][] and create a new
bucket, (i.e. `tecnativa-$PROJECT-bkp`). Then edit it and configure its
lifecycle (i.e. a rule named `10-glacier-100-delete` configured to move objects
to glacier mode after 10 days and delete them after 100).

[S3 Manager]: https://console.aws.amazon.com/s3/home

### Configure access permissions

Configure them through the
[IAM Manager](https://console.aws.amazon.com/iam/home).

You probably want to have a user and group per project. Usually these users
have no password because they will only access the services through API.

In such case, you need a policy to apply to that group (i.e. called
`s3-tecnativa-$PROJECT-bkp`), with this minimal configuration:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucketVersions",
                "s3:ListMultipartUploadParts",
                "s3:GetBucketAcl",
                "s3:GetBucketCORS",
                "s3:GetBucketLocation",
                "s3:GetBucketLogging",
                "s3:GetBucketNotification",
                "s3:GetBucketPolicy",
                "s3:GetBucketRequestPayment",
                "s3:GetBucketTagging",
                "s3:GetBucketVersioning",
                "s3:GetBucketWebsite",
                "s3:GetLifecycleConfiguration",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectTorrent",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectVersionTorrent"
            ],
            "Resource": "arn:aws:s3:::tecnativa-$PROJECT-bkp"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectTorrent",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectVersionTorrent"
            ],
            "Resource": "arn:aws:s3:::tecnativa-$PROJECT-bkp/*"
        }
    ]
}
```

Now create group (i.e. `tecnativa-$PROJECT-bkp`) if it does not exist and
attach the `s3-tecnativa-$PROJECT-bkp` policy to it.

Then create a user (i.e. `$PROJECT-bkp`), with only programatic access, and add
it to the `tecnativa-$PROJECT-bkp` group. You will then get the access key and
the secret key (you will never get the secret again!).

If you followed this procedure, then you should use these environment variables
for the container:

- `BACKUP_S3_BUCKET`: `tecnativa-$PROJECT-bkp`
- `BACKUP_S3_INSTANCE`: The name of your service for this customer
- `BACKUP_S3_ACCESS_KEY`: The access key obtained with the last step.
- `BACKUP_S3_SECRET_KEY`: The secret key obtained with the last step.

There are of course other variables that you can use, but these are the ones
that configure S3.
