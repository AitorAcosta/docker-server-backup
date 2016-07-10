FROM tecnativa/cron:latest

MAINTAINER antespi@gmail.com

ENV BACKUP_S3_ACCESS_KEY='__s3_access_key_to_change__' \
    BACKUP_S3_SECRET_KEY='__s3_secret_key_to_change__' \
    BACKUP_S3_REGION='eu-west-1' \
    BACKUP_S3_BUCKET='__bucket_name__' \
    BACKUP_S3_INSTANCE='__fqdn__' \
    BACKUP_SEND_MAIL_ERR=0 \
    BACKUP_SEND_MAIL_LOG=0 \
    BACKUP_EMAIL_SUBJECT="[__server_alias__]" \
    BACKUP_EMAIL_FROM='__from__@example.com' \
    BACKUP_EMAIL_TO='__to__@example.com' \
    BACKUP_EMAIL_CC='' \
    BACKUP_ENCRYPT=0 \
    BACKUP_ENCRYPT_KEY='__yourfavoritekey__' \
    BACKUP_SOURCES='/opt/source,0,1' \
    PG_HOST='postgresdb' \
    PG_USER='__pguser__' \
    PG_PASS='__pgpass__'

RUN apt-get update &&
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python-dateutil postgresql-client-9.5 && \
    git clone https://github.com/s3tools/s3cmd -b master /opt/s3cmd && \
    ln -s /opt/s3cmd/s3cmd /usr/bin/s3cmd && \
    git clone https://github.com/antespi/s3md5 -b master /opt/s3md5 && \
    ln -s /opt/s3md5/s3md5 /usr/bin/s3md5 && \
    git clone https://github.com/antespi/server-backup.git -b master /opt/server-backup && \
    mkdir -p /opt/backupdata

ADD config /opt/server-backup/config
ADD backup /etc/cron.d/
ADD croninit /usr/local/bin/
RUN chmod a+rx /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["tail", "-f", "/var/log/syslog"]
