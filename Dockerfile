FROM alpine:3.24
# Upstream image runs nginx + php-fpm under s6 as root and drops privileges, which
# fails under AiX --cap-drop=ALL. This variant runs PHP's built-in server as nobody.
RUN apk --no-cache add \
    tzdata ca-certificates php85 php85-phar php85-curl php85-json php85-zlib php85-xml php85-dom \
    php85-ctype php85-zip php85-iconv php85-pdo php85-pdo_sqlite php85-mbstring php85-session \
    php85-bcmath php85-gd php85-openssl php85-sockets php85-posix php85-simplexml php85-xmlwriter && \
    ln -sf /usr/bin/php85 /usr/bin/php
COPY . /var/www/app
RUN rm -rf /var/www/app/docker && \
    mkdir -p /var/lib/kanboard/data /var/www/app/plugins && \
    chown -R 65534:65534 /var/lib/kanboard /var/www/app/plugins
# Keep the SQLite file OUTSIDE the docroot (php -S would otherwise serve it).
ENV DATA_DIR=/var/lib/kanboard/data \
    PHP_CLI_SERVER_WORKERS=4
USER 65534:65534
WORKDIR /var/www/app
EXPOSE 3000
CMD ["php", "-S", "0.0.0.0:3000", "-t", "/var/www/app"]
