FROM php:7.0-apache
ARG HOST_UID=1000
RUN usermod --non-unique --uid $HOST_UID www-data &&\
    mkdir -m 777 /var/log/sql-injection
COPY src/index.html src/login.php /var/www/html/
COPY src/stats.html src/db.sqlite /var/www/
