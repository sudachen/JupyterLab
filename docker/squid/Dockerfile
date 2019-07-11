FROM ubuntu:18.04

RUN groupmod -g 1000 proxy && usermod -u 1000 -g proxy proxy

ENV DEBIAN_FRONTEND=noninteractive    

RUN apt-get update \
 && apt-get install -y \
    devscripts build-essential fakeroot debhelper dh-autoreconf cdbs \
    libcppunit-dev \
    libxml2-dev \
    libdb-dev \
    libexpat1-dev \
    libgnutls28-dev \
    libssl-dev 

ENV SQUID_VERSION=4.7 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/spool/squid/logs \
    SQUID_USER=proxy

RUN curl -L http://www.squid-cache.org/Versions/v4/squid-${SQUID_VERSION}.tar.bz2 \
         | tar jx -C /tmp \
 && ls /tmp

RUN set -ex \
 && cd /tmp/squid-${SQUID_VERSION} \
 && ./configure \
    --prefix=/usr \
    --with-openssl \
    --with-large-files \
    --with-default-user=proxy \
    --enable-ssl \
    --enable-ssl-crtd \
    --enable-inline \
    --enable-esi \
    --disable-arch-native \
    --enable-async-io=8 \
    --enable-storeio=aufs \
    --enable-removal-policies=lru,heap \
    --enable-delay-pools \
    --enable-cache-digests \
    --enable-follow-x-forwarded-for \
    --disable-auth \
    --disable-translation \
    --disable-dependency-tracking \
 && make 

RUN set -ex \
 && cd /tmp/squid-${SQUID_VERSION} \
 && make DESTDIR=/S install 

FROM ubuntu:18.04

RUN groupmod -g 1000 proxy && usermod -u 1000 -g proxy proxy

ENV SQUID_VERSION=4.7 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/spool/squid/logs \
    SQUID_USER=proxy

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libxml2 \
    libexpat1 \
    libltdl7 \
    libssl1.1 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=0 /S/usr /usr
COPY entrypoint.sh /sbin/entrypoint.sh
COPY squid.conf /etc/squid/squid.conf
COPY proxy-ca.pem proxy-ca.key proxy-ca.crt /etc/squid/ssl_cert/
COPY proxy-int.pem proxy-int.key proxy-int.crt /etc/squid/ssl_cert/
RUN set -ex \
 && chown proxy:proxy -R /etc/squid/ssl_cert \
 && chmod 700 /etc/squid/ssl_cert \
 && chmod 755 /sbin/entrypoint.sh \
 && /usr/libexec/security_file_certgen -c -s /var/lib/ssl_db -M 8MB \
 && chown proxy:proxy -R /var/lib/ssl_db
 
EXPOSE 3129/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
