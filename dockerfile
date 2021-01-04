FROM alpine:3.12.3

# add all packages
RUN apk update && apk upgrade && apk add \
	apache2-proxy \
	apache2-ssl \
	php7-fpm \
	php7 \
	php7-opcache \
	php7-gd \
	php7-json \
	php7-phar \
	php7-iconv \
	php7-mbstring \
	php7-zlib \
	php7-curl \
	php7-session \
	php7-redis \
	php7-pdo_mysql \
	php7-tokenizer \
	php7-dom \
	php7-simplexml \
	php7-xml \
	php7-ctype \
	php7-xdebug \
	curl \
	&& curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer  \
	&& composer global require drush/drush \
	&& composer clearcache \
	&& ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush \
	&& cp /usr/bin/php7 /usr/bin/php \
    && rm -f /var/cache/apk/* \
	&& rm -rf /etc/init.d/* \
    && addgroup -g 1000 -S http \
    && adduser -G http -u 1000 -s /bin/sh -D http \
	&& sed -rie 's|;error_log = log/php7/error.log|error_log = /dev/stdout|g' /etc/php7/php-fpm.conf 

# setup apache
COPY apache.conf /etc/apache2/httpd.conf
COPY php-pool.conf /etc/php7/php-fpm.d/www.conf
COPY xdebug.ini /etc/php7/conf.d/xdebug.ini 
COPY php.ini /etc/php7/php.ini

# setup entrypoint file and apply execution rights
ADD ./entrypoint.sh /bootstrap/entrypoint.sh
RUN chmod +x /bootstrap/entrypoint.sh

# expose on port 80 and set workdir
EXPOSE 80
WORKDIR /var/www

ADD ./web /var/www/public_html/

# send it
ENTRYPOINT ["/bootstrap/entrypoint.sh"]