FROM php:7.3.4-fpm-alpine3.9

LABEL maintainer="liuyuqiang <yuqiangliu@outlook.com>"

ENV LANG=C.UTF-8 \
    NGINX_VERSION=1.15.11 \
    LUA_MODULE_VERSION=0.10.14 \
    DEVEL_KIT_MODULE_VERSION=0.3.0 \
    LUAJIT_VERSION=2.1-20190329 \
    LUAJIT_LIB=/usr/lib \
    LUAJIT_INC=/usr/include/luajit-2.1

#enable php extension optional [yes/no]
ARG ENABLE_PHP_EXTENSION_XDEBUG=yes
ARG ENABLE_PHP_EXTENSION_GRPC=yes
ARG ENABLE_PHP_EXTENSION_SWOOLE=yes
ARG ENABLE_PHP_EXTENSION_YAF=yes
ARG ENABLE_PHP_EXTENSION_YAR=yes

RUN echo -n "enable php extension xdebug support:[yes/no]        " ; if [ "`echo "$ENABLE_PHP_EXTENSION_XDEBUG" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then echo "Yes"; else echo "No" ; fi && \
    echo -n "enable php extension grpc   support:[yes/no]        " ; if [ "`echo "$ENABLE_PHP_EXTENSION_GRPC"   | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then echo "Yes"; else echo "No" ; fi && \
    echo -n "enable php extension swoole support:[yes/no]        " ; if [ "`echo "$ENABLE_PHP_EXTENSION_SWOOLE" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then echo "Yes"; else echo "No" ; fi && \
    echo -n "enable php extension yaf    support:[yes/no]        " ; if [ "`echo "$ENABLE_PHP_EXTENSION_YAF"    | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then echo "Yes"; else echo "No" ; fi && \
    echo -n "enable php extension yar    support:[yes/no]        " ; if [ "`echo "$ENABLE_PHP_EXTENSION_YAR"    | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then echo "Yes"; else echo "No" ; fi

RUN set -ex \
    && apk update && apk upgrade && apk add --no-cache libgcc  \
    && apk add --no-cache --virtual .build-deps  ca-certificates openssl make  gcc  libc-dev \
    && curl -fSL https://github.com/openresty/luajit2/archive/v${LUAJIT_VERSION}.tar.gz | tar xzf - \
    && cd luajit2-${LUAJIT_VERSION} \
    && make -j"$(nproc)" PREFIX=/usr \
    && make install PREFIX=/usr \
    && cd .. \
    && rm -rf luajit2-${LUAJIT_VERSION} \
    && ln -sf /usr/bin/luajit /usr/bin/lua \
    && apk del .build-deps

RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
  && CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/data/logs/nginx/error.log \
    --http-log-path=/data/logs/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-debug \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --add-module=/usr/src/ngx_devel_kit-$DEVEL_KIT_MODULE_VERSION \
    --add-module=/usr/src/lua-nginx-module-$LUA_MODULE_VERSION \
  " \
  && addgroup -S nginx \
  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
  && apk add --no-cache --virtual .build-deps \
    autoconf \
    gcc \
    libc-dev \
    make \
	openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg1 \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
  && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
  && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
  && curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v$DEVEL_KIT_MODULE_VERSION.tar.gz -o ndk.tar.gz \
  && curl -fSL https://github.com/openresty/lua-nginx-module/archive/v$LUA_MODULE_VERSION.tar.gz -o lua.tar.gz \
  && export GNUPGHOME="$(mktemp -d)" \
  && found=''; \
  for server in \
    ha.pool.sks-keyservers.net \
    hkp://keyserver.ubuntu.com:80 \
    hkp://p80.pool.sks-keyservers.net:80 \
    pgp.mit.edu \
  ; do \
    echo "Fetching GPG key $GPG_KEYS from $server"; \
    gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
  done; \
  test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
  gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
  && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
  && mkdir -p /usr/src \
  && tar -zxC /usr/src -f nginx.tar.gz \
  && tar -zxC /usr/src -f ndk.tar.gz \
  && tar -zxC /usr/src -f lua.tar.gz \
  && rm nginx.tar.gz ndk.tar.gz lua.tar.gz \
  && cd /usr/src/nginx-$NGINX_VERSION \
  && ./configure $CONFIG --with-debug \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && mv objs/nginx objs/nginx-debug \
  && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
  && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
  && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
  && mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
  && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
  && ./configure $CONFIG \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && rm -rf /etc/nginx/html/ \
  && mkdir -p /etc/nginx/conf.d/ \
  && mkdir -p /usr/share/nginx/html/ \
  && install -m644 html/index.html /usr/share/nginx/html/ \
  && install -m644 html/50x.html /usr/share/nginx/html/ \
  && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
  && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
  && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
  && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
  && install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
  && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
  && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
  && strip /usr/sbin/nginx* \
  && strip /usr/lib/nginx/modules/*.so \
  && rm -rf /usr/src/nginx-$NGINX_VERSION \
  \
  # Bring in gettext so we can get `envsubst`, then throw
  # the rest away. To do this, we need to install `gettext`
  # then move `envsubst` out of the way so `gettext` can
  # be deleted completely, then move `envsubst` back.
  && apk add --no-cache --virtual .gettext gettext \
  && mv /usr/bin/envsubst /tmp/ \
  \
  && runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
  		| sort -u \
  )" \
  && apk add --no-cache --virtual .nginx-rundeps $runDeps \
  && apk del .build-deps \
  && apk del .gettext \
  && mv /tmp/envsubst /usr/local/bin/ \
  \
  # Bring in tzdata so users could set the timezones through the environment
  # variables
  && apk add --no-cache tzdata \
  #setting timezone
  && cp /usr/share/zoneinfo/UTC /etc/localtime \
  && echo "UTC" > /etc/TZ \
  \
  # forward request and error logs to docker log collector
  && ln -sf /dev/stdout /data/logs/nginx/access.log \
  && ln -sf /dev/stderr /data/logs/nginx/error.log


# resolves #166
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv iotop tshark && \
    apk add --no-cache tcpdump tcpflow nload iperf bind-tools net-tools sysstat strace ltrace tree readline screen vim && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ lrzsz && \
    # DEPENDENCY TO ALLOW USERS TO RUN crontab
    apk add --no-cache --update busybox-suid

RUN echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo /etc/apk/respositories && \
    apk update && apk upgrade &&\
    apk add --no-cache \
    bash \
    openssh-client \
    wget \
    supervisor \
    curl \
    libcurl \
    libzip-dev \
    bzip2-dev \
    imap-dev \
    openssl-dev \
    git \
    python \
    python-dev \
    py-pip \
    augeas-dev \
    ca-certificates \
    dialog \
    autoconf \
    make \
    gcc \
    musl-dev \
    linux-headers \
    libmcrypt-dev \
    libpng-dev \
    libwebp-dev \
    icu-dev \
    libpq \
    libxslt-dev \
    libffi-dev \
    freetype-dev \
    sqlite-dev \
    libjpeg-turbo-dev \
    postgresql-dev && \
    docker-php-ext-configure gd \
      --with-gd \
      --with-webp-dir=/usr/include/ \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install iconv pdo_mysql pdo_sqlite pgsql pdo_pgsql mysqli gd exif intl xsl json soap dom zip opcache bcmath pcntl && \
    pecl channel-update pecl.php.net && \
    pecl install -o -f redis && \
    docker-php-ext-enable redis && \
    pecl install -o -f mongodb && \
    docker-php-ext-enable mongodb && \
    pecl install apcu && \
    docker-php-ext-enable apcu && \
    docker-php-source delete && \
    mkdir -p /etc/nginx && \
    mkdir -p /data/project && \
    mkdir -p /run/nginx && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --quiet --install-dir=/usr/bin --filename=composer && \
    rm composer-setup.php && \
    pip install -U pip && \
    apk del gcc musl-dev linux-headers libffi-dev augeas-dev python-dev make autoconf libwebp-dev heimdal-dev

# Install protoc & Enable grpc
RUN if [ "`echo "$ENABLE_PHP_EXTENSION_GRPC" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then \
      apk add --no-cache --virtual .grpc-build-deps gcc autoconf make libc-dev g++ zlib zlib-dev linux-headers protobuf-dev protobuf && \
      pecl channel-update pecl.php.net && \
      pecl install -o -f protobuf && \
      pecl install -o -f grpc && \
      apk del .grpc-build-deps && \
      docker-php-ext-enable protobuf && \
      docker-php-ext-enable grpc && \
      echo "GRPC enabled"; \
    else \
      echo "GRPC skipping"; \
    fi

# Enable xdebug
RUN if [ "`echo "$ENABLE_PHP_EXTENSION_XDEBUG" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then \
      apk add --no-cache --virtual .xdebug-build-deps autoconf g++ make gcc && \
      pecl channel-update pecl.php.net && \
      pecl install -o -f xdebug && \
      apk del .xdebug-build-deps && \
      docker-php-ext-enable xdebug && \
      XdebugFile='/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini' && \
      echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > $XdebugFile && \
      echo "xdebug.remote_enable=1" >> $XdebugFile && \
      echo "xdebug.remote_autostart=false" >> $XdebugFile && \
      echo "remote_host=host.docker.internal" >> $XdebugFile && \
      echo "xdebug.remote_log=/tmp/xdebug.log" >> $XdebugFile && \
      echo "XDebug enabled"; \
    else \
      echo "XDebug skipping"; \
    fi

# Enable swoole
RUN if [ "`echo "$ENABLE_PHP_EXTENSION_SWOOLE" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then \
      apk add --no-cache --virtual .swoole-build-deps autoconf g++ make gcc && \
      pecl channel-update pecl.php.net && \
      yes | pecl install -o -f swoole && \
      apk del .swoole-build-deps && \
      docker-php-ext-enable swoole && \
      SwooleFile='/usr/local/etc/php/conf.d/docker-php-ext-swoole.ini' && \
      echo "[swoole]" > $SwooleFile && \
      echo "extension=$(find /usr/local/lib/php/extensions/ -name swoole.so)" >> $SwooleFile && \
      echo "Swoole enabled"; \
    else \
      echo "Swoole skipping"; \
    fi

# Enable yaf
RUN if [ "`echo "$ENABLE_PHP_EXTENSION_YAF" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then \
      apk add --no-cache --virtual .yaf-build-deps autoconf g++ make gcc && \
      pecl channel-update pecl.php.net && \
      pecl install -o -f yaf && \
      apk del .yaf-build-deps && \
      docker-php-ext-enable yaf && \
      YafFile='/usr/local/etc/php/conf.d/docker-php-ext-yaf.ini' && \
      echo "[Yaf]" > $YafFile && \
      echo "extension=$(find /usr/local/lib/php/extensions/ -name yaf.so)" >> $YafFile && \
      echo "yaf.environ=product" >> $YafFile && \
      echo "Yaf enabled"; \
    else \
      echo "Yaf skipping"; \
    fi

# Enable yar
RUN if [ "`echo "$ENABLE_PHP_EXTENSION_YAR" | tr '[:upper:]' '[:lower:]'`" == "yes" ]; then \
      apk add --no-cache --virtual .yar-build-deps autoconf g++ make gcc curl curl-dev libcurl && \
      pecl channel-update pecl.php.net && \
      echo no | pecl install -o -f yar && \
      apk del .yar-build-deps && \
      docker-php-ext-enable yar && \
      YarFile='/usr/local/etc/php/conf.d/docker-php-ext-yar.ini' && \
      echo "[Yar]" > $YarFile && \
      echo "extension=$(find /usr/local/lib/php/extensions/ -name yar.so)" >> $YarFile && \
      echo "yar.expose_info=Off" >> $YarFile && \
      echo "Yar enabled"; \
    else \
      echo "Yar skipping"; \
    fi

#Create supervisor & nginx & logs & data dir
RUN mkdir -p /data/project/supervisor/conf.d/ && \
    mkdir -p /etc/nginx/include/ && \
    mkdir -p /etc/nginx/ssl/ && \
    mkdir -p /data/project/www/ && \
    mkdir -p /data/logs/nginx/ && \
    mkdir -p /data/logs/supervisor/ && \
    ln -sf /dev/stdout /data/logs/supervisor/supervisord.log && \
    rm -Rf /var/www/* && \
    rm -Rf /etc/nginx/nginx.conf && \
    rm -Rf /usr/local/etc/php-fpm.d/*

# Copy custom config
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx/include/ /etc/nginx/include/
ADD conf/www/ /data/project/www/
ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/php/php.ini /usr/local/etc/php/php.ini
ADD conf/php/conf.d/ /usr/local/etc/php/conf.d/
ADD conf/php/php-fpm.conf /usr/local/etc/php-fpm.conf
ADD conf/php/php-fpm.d/ /usr/local/etc/php-fpm.d/
ADD scripts/start.sh /start.sh

RUN chown -Rf nginx:nginx /data/project/www/ && chmod 755 /start.sh

EXPOSE 80 443

STOPSIGNAL SIGTERM

WORKDIR "/data/project/www/"

CMD ["/start.sh"]
