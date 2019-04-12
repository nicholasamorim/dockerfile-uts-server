FROM debian:stretch-slim as builder
RUN apt-get -qq update; \
    apt-get -qq install -y --no-install-recommends ca-certificates curl git build-essential cmake clang libssl-dev openssl

ENV CIVETWEB_GITTAG=v1.11
ENV UTS_SERVER_COMMIT=225fbd29128854e75ca9664d8b6f262c0d1aaf88
ENV UTS_SERVER_DOWNLOAD_URL https://github.com/kakwa/uts-server/archive/$UTS_SERVER_COMMIT.tar.gz

WORKDIR /root
RUN set -ex; \
    curl -s -LO "$UTS_SERVER_DOWNLOAD_URL"; \
    tar -zxf $UTS_SERVER_COMMIT.tar.gz; \
    mv uts-server-$UTS_SERVER_COMMIT uts-server; \
    rm $UTS_SERVER_COMMIT.tar.gz; \
    cd uts-server; \
    cmake . -DBUNDLE_CIVETWEB=ON; \
    make; \
    ./tests/cfg/pki/create_tsa_certs; \
    sed -i 's/127.0.0.1/0.0.0.0/g' ./tests/cfg/uts-server.cnf; \
    sed -i 's/127.0.0.1/0.0.0.0/g' ./tests/cfg/uts-server-ssl.cnf; \
    sed -i '/^#.*run_as_user/s/^#//' ./tests/cfg/uts-server.cnf; \
    sed -i '/^#.*run_as_user/s/^#//' ./tests/cfg/uts-server-ssl.cnf; \
    sed -i 's/#run_as_user = uts-server/0.0.0.0/g' ./tests/cfg/uts-server.cnf; \
    sed -i 's/127.0.0.1/0.0.0.0/g' ./tests/cfg/uts-server-ssl.cnf; \
    sed -i 's/.*log_to_syslog.*/log_to_syslog = no/g' ./tests/cfg/uts-server.cnf; \
    sed -i 's/.*log_to_syslog.*/log_to_syslog = no/g' ./tests/cfg/uts-server-ssl.cnf; \
    sed -i 's/.*log_to_stdout.*/log_to_stdout = yes/g' ./tests/cfg/uts-server.cnf; \
    sed -i 's/.*log_to_stdout.*/log_to_stdout = yes/g' ./tests/cfg/uts-server-ssl.cnf;


FROM debian:stretch-slim

RUN groupadd -r uts-server && useradd -r -g uts-server uts-server
RUN mkdir /etc/uts-server && chown uts-server:uts-server /etc/uts-server && mkdir /opt/uts-server

VOLUME /etc/uts-server

RUN apt-get update; apt-get install -y --no-install-recommends ca-certificates;
COPY --from=builder /root/uts-server /opt/uts-server
RUN \
    ln -s /opt/uts-server/uts-server /usr/local/bin; \
    chown -R uts-server:uts-server /opt/uts-server
WORKDIR /opt/uts-server

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2020
CMD ["uts-server"]
