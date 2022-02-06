FROM alpine:3.15

ARG PROXY_VERSION=1.28.1
ARG MSSQLTOOLS_VERSION=17.8.1.1-1 # https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

COPY rootfs /

RUN addgroup alpine && adduser -S -D -G alpine alpine && \
    apk --no-cache add ca-certificates bash mariadb-client postgresql gnupg && \
# install MSSQL tools
	MSSQLTOOLS_URL=https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b && \
    wget -O /tmp/msodbcsql17.apk ${MSSQLTOOLS_URL}/msodbcsql17_${MSSQLTOOLS_VERSION}_amd64.apk && \
    wget -O /tmp/msodbcsql17.sig ${MSSQLTOOLS_URL}/msodbcsql17_${MSSQLTOOLS_VERSION}_amd64.sig && \
    wget -O /tmp/mssql-tools.apk ${MSSQLTOOLS_URL}/mssql-tools_${MSSQLTOOLS_VERSION}_amd64.apk && \
    wget -O /tmp/mssql-tools.sig ${MSSQLTOOLS_URL}/mssql-tools_${MSSQLTOOLS_VERSION}_amd64.sig && \
    wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --import - && \
    gpg --verify /tmp/msodbcsql17.sig /tmp/msodbcsql17.apk && \
    gpg --verify /tmp/mssql-tools.sig /tmp/mssql-tools.apk && \
    apk add --allow-untrusted /tmp/msodbcsql17.apk && \
    apk add --allow-untrusted /tmp/mssql-tools.apk && \
    for f in `find /opt/mssql-tools/bin/ -type f -executable`; do ln -s $f /usr/local/bin/`basename $f`; done && \
# install cloud_sql_proxy
    wget https://storage.googleapis.com/cloudsql-proxy/v${PROXY_VERSION}/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy && \
    chmod +x /usr/local/bin/cloud_sql_proxy /*.sh && \
# finalise and cleanup
    apk del gnupg && \
    rm -rf /apk /tmp/* /var/cache/apk/*

USER alpine
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
