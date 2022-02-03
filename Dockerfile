FROM alpine:3.14

COPY rootfs /

RUN addgroup alpine && adduser -S -D -G alpine alpine && \
    apk --no-cache add ca-certificates bash mariadb-client postgresql && \
    wget https://storage.googleapis.com/cloudsql-proxy/v1.28.1/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy && \
    chmod +x /usr/local/bin/cloud_sql_proxy /*.sh && \
# finalise and cleanup
    rm -rf /apk /tmp/* /var/cache/apk/*

USER alpine
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
