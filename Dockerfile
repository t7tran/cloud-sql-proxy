FROM alpine:3.9

COPY rootfs /

RUN apk --no-cache add ca-certificates bash && \
    wget https://storage.googleapis.com/cloudsql-proxy/v1.14/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy && \
    chmod +x /usr/local/bin/cloud_sql_proxy /*.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
