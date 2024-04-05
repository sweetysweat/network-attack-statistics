FROM php:7.0-apache
RUN mkdir -m 777 /var/log/app
COPY index.html /var/www/html
COPY login.php /var/www/html
COPY stats.html /var/www
COPY db.sqlite /var/www
