FROM debian:bullseye

WORKDIR /build
ARG JSMIN=jsmin-3.0.0

RUN apt update \
    && curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
    && rm -f /tmp/debsuryorg-archive-keyring.deb \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list' \
    && apt update -y \
    && apt install -y php8.1-dev php-pear wget \
    && wet https://pecl.php.net/get/${JSMIN}.tgz \
    && tar xzvf ${JSMIN}.tgz \
    && cd ${JSMIN} \
    && pipize \
    && ./configure --with-php-config=/usr/bin/php-config \
    && sed -ie "s/TSRMLS_(D|C)C//g" jsmin.h \
    && sed -ie "s/TSRMLS_(D|C)C//g" jsmin.c \
    && sed -ie "s/TSRMLS_(D|C)C//g" php_jsmin.h \
    && sed -ie "s/TSRMLS_(D|C)C//g" php_jsmin.c \
    && make \
    && mkdir -p /result \
    && cp modules/jsmin.so /result/jsmin.so \
    && echo "extention=jsmin.so" > /result/20-jsmin.ini \
    && apt-get remove php8.1-dev php-pear \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*