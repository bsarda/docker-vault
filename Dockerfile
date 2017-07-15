# written by Benoit Sarda
# hashicorp Vault container that uses a simple file backend.
#
#   bsarda <b.sarda@free.fr>
#
FROM alpine:latest
LABEL maintainer "b.sarda@free.fr"

# variables for certificate
ENV ENABLE_SSL=true \
    SSL_COUNTRY=FR \
    SSL_STATE=IDF \
    SSL_LOCALITY=Paris \
    SSL_ORG=Company \
    SSL_OU=IT

ARG ver=0.7.3
# july 2017 version!!

EXPOSE 8200 8201

# add files
ADD ["init.sh","stop.sh","/usr/local/bin/"]

RUN mkdir /data && mkdir /var/local/vault -p && apk --update add wget openssl ca-certificates && \
    openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout /var/local/vault/key.pem -out /var/local/vault/cert.pem -days 3650 -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORG/OU=$SSL_OU/CN=localhost" && \
    chmod 750 /usr/local/bin/init.sh && chmod 750 /usr/local/bin/stop.sh && \
    wget https://releases.hashicorp.com/vault/${ver}/vault_${ver}_linux_amd64.zip -P /tmp && unzip /tmp/vault_${ver}_linux_amd64.zip -d /bin && rm /tmp/vault_${ver}_linux_amd64.zip && \
    echo 'storage "file" {' > /var/local/vault/vault.conf && \
    echo '  path = "/data/vaultdata"' >> /var/local/vault/vault.conf && \
    echo '}' >> /var/local/vault/vault.conf && \
    echo 'listener "tcp" {' >> /var/local/vault/vault.conf && \
    echo '  address = "0.0.0.0:8200"' >> /var/local/vault/vault.conf && \
    echo '  tls_disable = 0' >> /var/local/vault/vault.conf && \
    echo '  tls_cert_file = "/data/cert.pem"' >> /var/local/vault/vault.conf && \
    echo '  tls_key_file = "/data/key.pem"' >> /var/local/vault/vault.conf && \
    echo '  tls_require_and_verify_client_cert = "false"' >> /var/local/vault/vault.conf && \
    echo '}' >> /var/local/vault/vault.conf && \
    echo 'disable_mlock = false' >> /var/local/vault/vault.conf

VOLUME "/data"

# default
CMD ["/usr/local/bin/init.sh"]
