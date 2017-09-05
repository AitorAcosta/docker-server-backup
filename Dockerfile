FROM tecnativa/cron:latest
MAINTAINER Tecnativa <info@tecnativa.com>

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

# Install everything required
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        zip \
        python-dateutil \
        python-magic \
        wget \
        net-tools \
        vim-common \
        bzip2 && \
    echo deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main \
        > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | apt-key add - && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-client && \
    apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/cache/apt/archives/* /var/cache/apt/*.bin /var/lib/apt/lists/* && \
    echo "Downloading s3cmd ..." && \
    wget -qO- https://github.com/s3tools/s3cmd/archive/master.tar.gz | tar -xzC /opt && \
    ln -s /opt/s3cmd-master/s3cmd /usr/bin/s3cmd && \
    echo "Downloading s3md5 ..." && \
    wget -qO- https://github.com/antespi/s3md5/archive/master.tar.gz | tar -xzC /opt && \
    ln -s /opt/s3md5-master/s3md5 /usr/bin/s3md5 && \
    echo "Downloading server-backup ..." && \
    wget -qO- https://github.com/antespi/server-backup/archive/docker.tar.gz | tar -xzC /opt && \
    mv /opt/server-backup-docker /opt/server-backup && \
    mkdir -p /opt/backupdata && \
    mkdir -p /opt/source

VOLUME ["/opt/backupdata", "/opt/source"]

ADD config /opt/server-backup/config
ADD backup /etc/cron.d/
ADD croninit restore /usr/local/bin/
RUN chmod a+rx /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["tail", "-f", "/var/log/syslog"]
