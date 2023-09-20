FROM alpine:3.18

ARG PROXY_VERSION=2.7.0
ARG MSSQLTOOLS_VERSION=18_18.3.1.1-1 # https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15
ARG MSSQLTOOLS_URL=https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5

COPY rootfs /

RUN addgroup alpine && adduser -S -D -G alpine alpine && \
    apk --no-cache add ca-certificates bash mariadb-client mariadb-connector-c postgresql gnupg && \
# install MSSQL tools
    wget -O /tmp/msodbcsql.apk ${MSSQLTOOLS_URL}/msodbcsql${MSSQLTOOLS_VERSION}_amd64.apk && \
    wget -O /tmp/msodbcsql.sig ${MSSQLTOOLS_URL}/msodbcsql${MSSQLTOOLS_VERSION}_amd64.sig && \
    wget -O /tmp/mssql-tools.apk ${MSSQLTOOLS_URL}/mssql-tools${MSSQLTOOLS_VERSION}_amd64.apk && \
    wget -O /tmp/mssql-tools.sig ${MSSQLTOOLS_URL}/mssql-tools${MSSQLTOOLS_VERSION}_amd64.sig && \
    wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --import - && \
    gpg --verify /tmp/msodbcsql.sig /tmp/msodbcsql.apk && \
    gpg --verify /tmp/mssql-tools.sig /tmp/mssql-tools.apk && \
    apk add --allow-untrusted /tmp/msodbcsql.apk && \
    apk add --allow-untrusted /tmp/mssql-tools.apk && \
    for f in `find /opt/mssql-tools*/bin/ -type f -executable`; do ln -s $f /usr/local/bin/`basename $f`; done && \
# install cloud_sql_proxy
    wget https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${PROXY_VERSION}/cloud-sql-proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy && \
    chmod +x /usr/local/bin/cloud_sql_proxy /*.sh && \
# finalise and cleanup
    apk del gnupg && \
    rm -rf /apk /tmp/* /var/cache/apk/*

USER alpine
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
